import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "jsr:@supabase/server@^1";

interface GenerateDesignPayload {
  prompt: string;
  image_base64?: string;
  image_mime_type?: string;
}

const MODEL = "gpt-image-1.5";

function decodeBase64(value: string): Uint8Array {
  const raw = value.includes(",") ? value.split(",").pop() ?? "" : value;
  const binary = atob(raw);
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

export default {
  fetch: withSupabase({ auth: "user" }, async (req) => {
    if (req.method !== "POST") {
      return Response.json({ error: "Method not allowed" }, { status: 405 });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return Response.json(
        { error: "OPENAI_API_KEY is not configured" },
        { status: 500 },
      );
    }

    let payload: GenerateDesignPayload;
    try {
      payload = await req.json();
    } catch {
      return Response.json({ error: "Invalid JSON request" }, { status: 400 });
    }

    const prompt = payload.prompt?.trim();
    if (!prompt || prompt.length < 3) {
      return Response.json(
        { error: "Please enter a design description" },
        { status: 400 },
      );
    }

    let openAiResponse: Response;

    if (payload.image_base64) {
      const imageBytes = decodeBase64(payload.image_base64);
      const form = new FormData();
      form.append("model", MODEL);
      form.append("prompt", prompt);
      form.append("size", "1024x1024");
      form.append("quality", "medium");
      form.append("output_format", "png");
      form.append(
        "image",
        new Blob([imageBytes], {
          type: payload.image_mime_type || "image/jpeg",
        }),
        "source-image",
      );

      openAiResponse = await fetch("https://api.openai.com/v1/images/edits", {
        method: "POST",
        headers: { Authorization: `Bearer ${apiKey}` },
        body: form,
      });
    } else {
      openAiResponse = await fetch(
        "https://api.openai.com/v1/images/generations",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: MODEL,
            prompt,
            size: "1024x1024",
            quality: "medium",
            output_format: "png",
          }),
        },
      );
    }

    const result = await openAiResponse.json();

    if (!openAiResponse.ok) {
      console.error("OpenAI image request failed", result);
      return Response.json(
        {
          error:
            result?.error?.message ||
            "The AI image service could not generate this design",
        },
        { status: openAiResponse.status },
      );
    }

    const imageBase64 = result?.data?.[0]?.b64_json;
    if (!imageBase64) {
      return Response.json(
        { error: "The AI service returned no image" },
        { status: 502 },
      );
    }

    return Response.json({
      image_base64: imageBase64,
      mime_type: "image/png",
      model: MODEL,
    });
  }),
};
