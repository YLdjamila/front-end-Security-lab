import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// Configuration. The API address is a constant, not a security control.
// Use HTTPS (https://...) when the app is deployed.
// ---------------------------------------------------------------------------
const String baseUrl = 'http://10.40.60.63/lab_sec_backend';
const Duration _requestTimeout = Duration(seconds: 10);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Product Shop',
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Session: the token lives in memory only (never shown, never logged).
// The role is kept ONLY to adapt the UI; PHP re-checks the real role from
// MySQL on every protected request.
// ---------------------------------------------------------------------------
class Session {
  static String token = '';
  static String name = '';
  static String role = '';

  static bool get loggedIn => token.isNotEmpty;
  static bool get isManager => role == 'manager';

  static void clear() {
    token = '';
    name = '';
    role = '';
  }
}

void _goToLogin(String notice) {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginScreen(notice: notice)),
        (route) => false,
  );
}

// A 401 on a protected call means the token is missing, expired or revoked.
void _sessionExpired() {
  if (!Session.loggedIn) return;
  Session.clear();
  _goToLogin('Your session expired. Please sign in again.');
}

// ---------------------------------------------------------------------------
// API helper: POST form fields -> decode JSON -> never throws.
// ---------------------------------------------------------------------------
class ApiResponse {
  final int status; // 0 = no HTTP response (network error / timeout)
  final dynamic data;
  const ApiResponse(this.status, this.data);

  bool get ok => status >= 200 && status < 300;

  String get error => (data is Map && data['error'] != null)
      ? data['error'].toString()
      : 'Unexpected server response';

  String get message =>
      (data is Map && data['message'] != null) ? data['message'].toString() : '';
}

class Api {
  static Future<ApiResponse> post(
      String endpoint,
      Map<String, String> body, {
        bool auth = false,
      }) async {
    final payload = Map<String, String>.from(body);
    if (auth) payload['token'] = Session.token;

    try {
      final res = await http
          .post(Uri.parse('$baseUrl/$endpoint'), body: payload)
          .timeout(_requestTimeout);

      dynamic data;
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        data = {'error': 'Unexpected server response'};
      }

      if (auth && res.statusCode == 401) _sessionExpired();
      return ApiResponse(res.statusCode, data);
    } on TimeoutException {
      return const ApiResponse(0, {'error': 'The server took too long to respond'});
    } catch (_) {
      return const ApiResponse(0, {'error': 'Could not contact the server'});
    }
  }
}

// ===========================================================================
// LOGIN / REGISTER SCREEN
// ===========================================================================
class LoginScreen extends StatefulWidget {
  final String? notice;
  const LoginScreen({super.key, this.notice});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _registerMode = false;
  bool _loading = false;
  bool _hidePassword = true;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _message = widget.notice;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // Convenience checks only. The server repeats and enforces every rule.
  String? _validate() {
    final email = _email.text.trim();
    final pw = _password.text;

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ||
        email.length > 190) {
      return 'Enter a valid email address.';
    }
    if (_registerMode) {
      final name = _name.text.trim();
      if (name.isEmpty || name.length > 100) {
        return 'Enter your name (max 100 characters).';
      }
      final bytes = utf8.encode(pw).length;
      if (bytes < 15 || bytes > 72) {
        return 'Password must be between 15 and 72 characters.';
      }
      if (pw != _confirm.text) return 'The two passwords do not match.';
    } else {
      if (pw.isEmpty) return 'Enter your password.';
      if (utf8.encode(pw).length > 72) return 'Email or password incorrect';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;
    final problem = _validate();
    if (problem != null) {
      setState(() {
        _message = problem;
        _isError = true;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });

    if (_registerMode) {
      await _register();
    } else {
      await _login();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _login() async {
    final res = await Api.post('login.php', {
      'email': _email.text.trim(),
      'password': _password.text,
    });
    if (!mounted) return;

    if (res.status == 200 && res.data is Map && res.data['token'] is String) {
      Session.token = res.data['token'];
      Session.name = res.data['name']?.toString() ?? '';
      Session.role = res.data['role']?.toString() ?? '';
      _password.clear(); // do not keep the password in memory longer than needed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _password.clear();
      setState(() {
        _message = res.error; // 401 / 429 messages come from PHP
        _isError = true;
      });
    }
  }

  Future<void> _register() async {
    final res = await Api.post('register.php', {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
    });
    if (!mounted) return;

    setState(() {
      if (res.status == 201) {
        _registerMode = false; // registration gives no token: log in next
        _password.clear();
        _confirm.clear();
        _message = res.message;
        _isError = false;
      } else {
        _message = res.error;
        _isError = true;
      }
    });
  }

  void _toggleMode() {
    setState(() {
      _registerMode = !_registerMode;
      _message = null;
      _password.clear();
      _confirm.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_outline, size: 56, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      _registerMode ? 'Create an account' : 'Sign in',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    if (_registerMode) ...[
                      TextField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [LengthLimitingTextInputFormatter(190)],
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: _hidePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: _registerMode
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: (_) {
                        if (!_registerMode) _submit();
                      },
                      autofillHints: [
                        _registerMode
                            ? AutofillHints.newPassword
                            : AutofillHints.password
                      ],
                      decoration: InputDecoration(
                        labelText: _registerMode
                            ? 'Password (15-72 characters)'
                            : 'Password',
                        prefixIcon: const Icon(Icons.key_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip:
                          _hidePassword ? 'Show password' : 'Hide password',
                          icon: Icon(_hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                    ),
                    if (_registerMode) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirm,
                        obscureText: _hidePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.key_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isError ? scheme.error : Colors.green[800],
                          ),
                        ),
                      ),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(_registerMode ? 'Create account' : 'Log in'),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _toggleMode,
                      child: Text(_registerMode
                          ? 'Already have an account? Log in'
                          : 'No account? Create one'),
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

// ===========================================================================
// HOME SCREEN: product list + exact-name search (signed-in users)
// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  List<dynamic> _products = [];
  String? _error;
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetch(String endpoint, Map<String, String> body,
      {required bool searched}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await Api.post(endpoint, body, auth: true);
    if (!mounted) return; // e.g. session expired -> already sent to login

    setState(() {
      _loading = false;
      if (res.ok && res.data is List) {
        _products = res.data;
        _searched = searched;
      } else {
        _error = res.error;
      }
    });
  }

  Future<void> _load() => _fetch('list.php', {}, searched: false);

  Future<void> _runSearch() async {
    final term = _search.text.trim();
    if (term.isEmpty) {
      await _load();
    } else {
      await _fetch('search.php', {'name': term}, searched: true);
    }
  }

  Future<void> _logout() async {
    final res = await Api.post('logout.php', {}, auth: true);
    if (!mounted) return; // a 401 already cleared the session
    if (res.status == 200) {
      Session.clear();
      _goToLogin('You have been logged out.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout not confirmed. Try again.')),
      );
    }
  }

  Future<void> _openUpdate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpdatePriceScreen()),
    );
    if (mounted && Session.loggedIn) _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                avatar: Icon(
                  Session.isManager
                      ? Icons.admin_panel_settings_outlined
                      : Icons.person_outline,
                  size: 18,
                ),
                label: Text('${Session.name} (${Session.role})'),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _runSearch(),
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    decoration: const InputDecoration(
                      labelText: 'Exact product name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _runSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _openUpdate,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Change price'),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              ),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _products.isEmpty && !_loading && _error == null
                  ? Center(
                child: Text(_searched
                    ? 'No product with this exact name.'
                    : 'No products.'),
              )
                  : ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, i) {
                  final p = _products[i];
                  return ListTile(
                    title: Text(p['name']?.toString() ?? ''),
                    subtitle: Text('id: ${p['id']}'),
                    trailing: Text('\$${p['price']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// UPDATE PRICE SCREEN
// The button is visible to everyone on purpose: a hidden button is not
// security. PHP answers 403 unless the verified account is a manager.
// ===========================================================================
class UpdatePriceScreen extends StatefulWidget {
  const UpdatePriceScreen({super.key});

  @override
  State<UpdatePriceScreen> createState() => _UpdatePriceScreenState();
}

class _UpdatePriceScreenState extends State<UpdatePriceScreen> {
  final _id = TextEditingController();
  final _price = TextEditingController();
  String? _message;
  bool _isError = false;
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final id = _id.text.trim();
    final price = _price.text.trim();

    // Convenience checks; PHP enforces the same policy.
    if (!RegExp(r'^\d{1,9}$').hasMatch(id) || int.parse(id) < 1) {
      setState(() {
        _message = 'Product ID must be a positive whole number.';
        _isError = true;
      });
      return;
    }
    if (!RegExp(r'^\d{1,5}(\.\d{1,2})?$').hasMatch(price) ||
        double.parse(price) > 10000) {
      setState(() {
        _message = 'Price must be between 0 and 10000 (max 2 decimals).';
        _isError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });
    final res = await Api.post('update.php', {'id': id, 'price': price}, auth: true);
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (res.ok) {
        _message = res.message.isEmpty ? 'Price updated.' : res.message;
        _isError = false;
      } else {
        _message = res.error; // e.g. 403 "Manager access required"
        _isError = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Change price')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _id,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: const InputDecoration(
                labelText: 'Product ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: const InputDecoration(
                labelText: 'New price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _update,
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Update price'),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isError ? scheme.error : Colors.green[800],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}