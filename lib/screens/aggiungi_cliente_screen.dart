import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cliente_model.dart';

class AggiungiClienteScreen extends StatefulWidget {
  const AggiungiClienteScreen({super.key});

  @override
  State<AggiungiClienteScreen> createState() => _AggiungiClienteScreenState();
}

class _AggiungiClienteScreenState extends State<AggiungiClienteScreen> {
  final nomeController = TextEditingController();
  final indirizzoController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final partitaIvaController = TextEditingController();
  final codiceUnivocoController = TextEditingController();

  late Box<ClienteModel> clienteBox;

  @override
  void initState() {
    super.initState();
    clienteBox = Hive.box<ClienteModel>('clienti');
  }

  void _salvaCliente() {
    final nuovoCliente = ClienteModel(
      nome: nomeController.text,
      indirizzo: indirizzoController.text,
      telefono: telefonoController.text,
      email: emailController.text,
      piva: partitaIvaController.text,
      codiceUnivoco: codiceUnivocoController.text,
    );

    clienteBox.add(nuovoCliente);
    setState(() {}); // aggiorna la lista
    Navigator.pop(context); // torna alla schermata precedente
  }

  void _eliminaCliente(int index) {
    clienteBox.deleteAt(index);
    setState(() {}); // aggiorna la lista
  }

  @override
  Widget build(BuildContext context) {
    final clienti = clienteBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo Cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: indirizzoController,
              decoration: const InputDecoration(labelText: 'Indirizzo'),
            ),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: partitaIvaController,
              decoration: const InputDecoration(labelText: 'Partita IVA'),
            ),
            TextField(
              controller: codiceUnivocoController,
              decoration: const InputDecoration(labelText: 'Codice Univoco'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvaCliente,
              child: const Text('Salva'),
            ),
            const Divider(height: 40),
            const Text(
              "Clienti salvati",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(clienti.length, (index) {
              final c = clienti[index];
              return Card(
                child: ListTile(
                  title: Text(c.nome),
                  subtitle: Text('${c.indirizzo} • ${c.email}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminaCliente(index),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
