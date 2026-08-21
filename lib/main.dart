import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://nhfukxnghmsslkmxwqde.supabase.co';
const _supabasePublishableKey =
    'sb_publishable_oA5FHUt3KweVEFXCToyoaQ_5AJ0YZJb';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabasePublishableKey,
  );
  runApp(const MGDesignStudioApp());
}

final supabase = Supabase.instance.client;

class MGDesignStudioApp extends StatelessWidget {
  const MGDesignStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF5B35D5);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MG AI Design Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session == null) {
          return const AuthPage();
        }
        return HomePage(key: ValueKey(session.user.id));
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUp) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (!mounted) return;
        if (response.session == null) {
          setState(() {
            _messageIsError = false;
            _message =
                'Account created. Please confirm the email sent to $email, then sign in.';
            _isSignUp = false;
          });
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _messageIsError = true;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messageIsError = true;
        _message = 'Unable to connect. Please check your internet and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MG AI Design Studio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Create your account'
                          : 'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: _isSignUp
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Password must contain at least 6 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: _messageIsError
                              ? colorScheme.errorContainer
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _messageIsError
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_isSignUp ? Icons.person_add : Icons.login),
                      label: Text(_isSignUp ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() {
                                _isSignUp = !_isSignUp;
                                _message = null;
                              }),
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _promptController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  Map<String, dynamic>? _subscription;
  int _designCount = 0;
  bool _loadingDashboard = true;
  bool _savingDraft = false;

  User get _user => supabase.auth.currentUser!;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    try {
      final subscription = await supabase
          .from('subscriptions')
          .select(
            'plan_name, status, monthly_credits, credits_used, expires_at',
          )
          .eq('user_id', _user.id)
          .maybeSingle();
      final designs = await supabase
          .from('designs')
          .select('id')
          .eq('user_id', _user.id);
      await _logAction('app_open');
      if (!mounted) return;
      setState(() {
        _subscription = subscription;
        _designCount = designs.length;
      });
    } catch (error) {
      if (mounted) {
        _showSnack('Dashboard data could not be loaded: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loadingDashboard = false);
    }
  }

  Future<void> _logAction(String action) async {
    try {
      await supabase.from('usage_logs').insert({
        'user_id': _user.id,
        'action': action,
        'app_version': '0.3.0',
        'device_info': Platform.operatingSystem,
      });
    } catch (_) {
      // Analytics must never block the user experience.
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2400,
      );
      if (image == null || !mounted) return;
      setState(() => _selectedImage = image);
      await _logAction(
        source == ImageSource.camera ? 'camera_selected' : 'gallery_selected',
      );
    } catch (error) {
      if (mounted) {
        _showSnack('Image could not be opened: $error', isError: true);
      }
    }
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty && _selectedImage == null) {
      _showSnack('Add a design description or select an image first.');
      return;
    }
    setState(() => _savingDraft = true);
    try {
      final shortTitle = prompt.isEmpty
          ? 'Image design draft'
          : (prompt.length > 45 ? '${prompt.substring(0, 45)}…' : prompt);
      await supabase.from('designs').insert({
        'user_id': _user.id,
        'title': shortTitle,
        'prompt': prompt,
        'design_type': 'draft',
        'status': 'draft',
        'project_data': {
          'has_local_image': _selectedImage != null,
          'source': 'mg_mobile_app',
        },
      });
      await _logAction('design_draft_saved');
      if (!mounted) return;
      _showSnack('Project draft saved in My Designs.');
      setState(() => _designCount += 1);
    } catch (error) {
      if (mounted) {
        _showSnack('Draft could not be saved: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
  }

  Future<void> _showAiStatus() async {
    await _logAction('ai_generate_tapped');
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome),
        title: const Text('AI service is the next integration'),
        content: const Text(
          'Login, camera/gallery, subscription data and design history are now connected. '
          'AI generation needs a protected server API key, which will be added through a Supabase Edge Function.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _signOut() async {
    await _logAction('sign_out');
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthlyCredits =
        (_subscription?['monthly_credits'] as num?)?.toInt() ?? 10;
    final usedCredits =
        (_subscription?['credits_used'] as num?)?.toInt() ?? 0;
    final availableCredits =
        (monthlyCredits - usedCredits).clamp(0, monthlyCredits);
    final planName = _subscription?['plan_name']?.toString() ?? 'Free';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MG AI Design Studio',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Icon(Icons.person_outline)),
            onSelected: (value) {
              if (value == 'logout') _signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: SizedBox(
                  width: 230,
                  child: Text(
                    _user.email ?? 'Signed-in user',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create something remarkable',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_loadingDashboard)
                    const LinearProgressIndicator()
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _StatChip(
                          icon: Icons.workspace_premium_outlined,
                          label: '$planName plan',
                        ),
                        _StatChip(
                          icon: Icons.bolt_outlined,
                          label: '$availableCredits credits',
                        ),
                        _StatChip(
                          icon: Icons.design_services_outlined,
                          label: '$_designCount designs',
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _promptController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Describe your design',
                hintText:
                    'Example: Modern dairy banner, green farm background, white desi cow…',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 72),
                  child: Icon(Icons.edit_note),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton.filledTonal(
                        onPressed: () => setState(() => _selectedImage = null),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            OutlinedButton.icon(
              onPressed: _showImageSourcePicker,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Camera / Gallery'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _showAiStatus,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Design with AI'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _savingDraft ? null : _saveDraft,
              icon: _savingDraft
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save project draft'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _NavigationCard(
                    icon: Icons.folder_copy_outlined,
                    title: 'My Designs',
                    subtitle: '$_designCount saved',
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyDesignsPage(),
                        ),
                      );
                      _loadDashboard();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavigationCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Subscription',
                    subtitle: planName,
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubscriptionPage(
                          subscription: _subscription,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDesignsPage extends StatefulWidget {
  const MyDesignsPage({super.key});

  @override
  State<MyDesignsPage> createState() => _MyDesignsPageState();
}

class _MyDesignsPageState extends State<MyDesignsPage> {
  late Future<List<Map<String, dynamic>>> _designsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _designsFuture = supabase
        .from('designs')
        .select('id, title, prompt, status, file_format, created_at')
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .then((rows) => List<Map<String, dynamic>>.from(rows));
  }

  Future<void> _refreshAndWait() async {
    setState(_refresh);
    await _designsFuture;
  }

  Future<void> _deleteDesign(Map<String, dynamic> design) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this design?'),
        content: Text(design['title']?.toString() ?? 'Untitled design'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await supabase.from('designs').delete().eq('id', design['id']);
    if (!mounted) return;
    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Designs')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _designsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Design history could not be loaded: ${snapshot.error}'),
              ),
            );
          }
          final designs = snapshot.data ?? [];
          if (designs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_outlined, size: 64),
                    SizedBox(height: 14),
                    Text(
                      'No designs saved yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text('Save a project draft from the home screen.'),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshAndWait,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: designs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final design = designs[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.design_services_outlined),
                    ),
                    title: Text(design['title']?.toString() ?? 'Untitled'),
                    subtitle: Text(
                      '${design['status'] ?? 'draft'} • ${_shortDate(design['created_at'])}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteDesign(design),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _shortDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return 'Unknown date';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({required this.subscription, super.key});

  final Map<String, dynamic>? subscription;

  @override
  Widget build(BuildContext context) {
    final monthly = (subscription?['monthly_credits'] as num?)?.toInt() ?? 10;
    final used = (subscription?['credits_used'] as num?)?.toInt() ?? 0;
    final progress = monthly == 0 ? 0.0 : (used / monthly).clamp(0.0, 1.0);
    final remaining = (monthly - used).clamp(0, monthly);
    final plan = subscription?['plan_name']?.toString() ?? 'Free';
    final status = subscription?['status']?.toString() ?? 'active';

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.workspace_premium, size: 44),
                  const SizedBox(height: 14),
                  Text(
                    '$plan plan',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Status: $status'),
                  const SizedBox(height: 22),
                  Text('$remaining of $monthly credits remaining'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: Text('Plan data is connected to Supabase'),
            subtitle: Text(
              'Paid plan checkout and automatic payment verification will be added with the payment gateway.',
            ),
          ),
        ],
      ),
    );
  }
}
