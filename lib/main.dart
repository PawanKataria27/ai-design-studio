import 'package:flutter/material.dart';

void main() {
  runApp(const AIDesignStudio());
}

class AIDesignStudio extends StatelessWidget {
  const AIDesignStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Design Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Design Studio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 20),

            const Icon(
              Icons.auto_awesome,
              size: 70,
            ),

            const SizedBox(height: 15),

            const Text(
              'Create Amazing Designs with AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Upload a photo or describe your design and let AI create it for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 35),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Camera / Gallery',
                style: TextStyle(fontSize: 17),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(17),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                'Generate Design with AI',
                style: TextStyle(fontSize: 17),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(17),
              ),
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text(
                'My Designs',
                style: TextStyle(fontSize: 17),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(17),
              ),
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.workspace_premium),
              label: const Text(
                'Subscription Plans',
                style: TextStyle(fontSize: 17),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(17),
              ),
            ),

            const SizedBox(height: 30),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      'Premium Features',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('✓ AI Design Generation'),
                    Text('✓ HD PNG / JPG Export'),
                    Text('✓ Custom Banner Sizes'),
                    Text('✓ Camera & Gallery'),
                    Text('✓ Design History'),
                    Text('✓ Premium Templates'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
