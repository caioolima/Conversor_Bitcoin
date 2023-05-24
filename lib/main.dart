import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(BitcoinConverterApp());
}

class BitcoinConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Converter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'PressStart2P',
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isButtonDisabled = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Lógica de autenticação
    if (username == 'Caio' && password == 'dev123') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BitcoinConverterPage(username: username)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro de Login'),
          content: Text('Usuário ou senha incorretos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Up Bit'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            onChanged: _validateInputs,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 107, 33, 243),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o usuário';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isButtonDisabled ? null : _login,
                  child: Text('Fazer Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BitcoinConverterPage extends StatefulWidget {
  final String username;

  BitcoinConverterPage({required this.username});

  @override
  _BitcoinConverterPageState createState() => _BitcoinConverterPageState();
}

class _BitcoinConverterPageState extends State<BitcoinConverterPage> {
  double bitcoinPrice = 0.0;
  double bitcoinAmount = 0.0;
  double usdValue = 0.0;
  bool isCalculating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> conversionHistory = [];

  Future<double> fetchBitcoinPrice() async {
    final response = await http.get(
      Uri.parse(
          'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['bitcoin']['usd'].toDouble();
    } else {
      throw Exception('Não foi possível obter a cotação do Bitcoin.');
    }
  }

  void calculateUSDValue() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isCalculating = true;
      });

      usdValue = bitcoinPrice * bitcoinAmount;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Resultado'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quantidade de Bitcoin: $bitcoinAmount',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Valor em USD: \$${usdValue.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addToConversionHistory(bitcoinAmount, usdValue);
                Navigator.pop(context);
              },
              child: Text('Fechar'),
            ),
          ],
        ),
      );

      setState(() {
        isCalculating = false;
      });
    }
  }

  void addToConversionHistory(double amount, double usdValue) {
    final conversion = {
      'amount': amount,
      'usdValue': usdValue,
      'timestamp': DateTime.now(),
    };
    conversionHistory.add(conversion);
  }

  @override
  void initState() {
    super.initState();
    fetchBitcoinPrice().then((price) {
      setState(() {
        bitcoinPrice = price;
      });
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bitcoin Converter',
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ConversionHistoryPage(conversionHistory)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Olá, ${widget.username}.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 107, 33, 243),
                ),
              ),
              SizedBox(height: 16),
              Text('Valor atual do Bitcoin:', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(
                '\$${bitcoinPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversão de Bitcoin para USD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 107, 33, 243),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          bitcoinAmount = double.parse(value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quantidade de Bitcoin';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Quantidade de Bitcoin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isCalculating ? null : calculateUSDValue,
                      child: Text('Converter'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversionHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> conversionHistory;

  ConversionHistoryPage(this.conversionHistory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Conversões'),
      ),
      body: ListView.builder(
        itemCount: conversionHistory.length,
        itemBuilder: (context, index) {
          final conversion = conversionHistory[index];
          final amount = conversion['amount'];
          final usdValue = conversion['usdValue'];
          final timestamp = conversion['timestamp'];

          final formattedTimestamp =
              DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

          return ListTile(
            leading: Icon(Icons.history),
            title: Text('BTC: $amount - USD: \$${usdValue.toStringAsFixed(2)}'),
            subtitle: Text(formattedTimestamp),
          );
        },
      ),
    );
  }
}
