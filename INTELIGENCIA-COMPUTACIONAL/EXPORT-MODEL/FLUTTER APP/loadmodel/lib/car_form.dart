import 'package:flutter/material.dart';
import 'onnx_service.dart';

class CarForm extends StatefulWidget {
  const CarForm({super.key});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _service = OnnxService();

  final yearCtrl = TextEditingController();
  final engineCtrl = TextEditingController();
  final hpCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();

  String brand = 'Toyota';
  String body = 'SUV';
  String fuel = 'Petrol';
  String transmission = 'Automatic';

  double? price;
  double? budget;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _service.loadModel().then((_) {
      setState(() => loading = false);
    });
  }

  String? validate() {
    if (yearCtrl.text.isEmpty ||
        engineCtrl.text.isEmpty ||
        hpCtrl.text.isEmpty ||
        mileageCtrl.text.isEmpty ||
        budgetCtrl.text.isEmpty) {
      return 'Todos los campos son obligatorios';
    }
    if (int.parse(yearCtrl.text) < 2000) return 'Año inválido';
    return null;
  }

  @override
  void dispose() {
    yearCtrl.dispose();
    engineCtrl.dispose();
    hpCtrl.dispose();
    mileageCtrl.dispose();
    budgetCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: yearCtrl,
            decoration: const InputDecoration(labelText: 'Año'),
          ),
          TextField(
            controller: engineCtrl,
            decoration: const InputDecoration(labelText: 'Engine CC'),
          ),
          TextField(
            controller: hpCtrl,
            decoration: const InputDecoration(labelText: 'Horsepower'),
          ),
          TextField(
            controller: mileageCtrl,
            decoration: const InputDecoration(labelText: 'Mileage km/l'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: budgetCtrl,
            decoration: const InputDecoration(
              labelText: 'Presupuesto (USD)',
              hintText: 'Ej: 15000',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),

          const SizedBox(height: 14),

          DropdownButton<String>(
            value: brand,
            items: [
              'Toyota',
              'Ford',
              'BMW',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => brand = v!),
          ),

          ElevatedButton(
            onPressed: () async {
              final error = validate();
              if (error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
                return;
              }

              final result = await _service.predict(
                year: int.parse(yearCtrl.text),
                engineCC: int.parse(engineCtrl.text),
                horsepower: int.parse(hpCtrl.text),
                mileage: double.parse(mileageCtrl.text),
                brand: brand,
                bodyType: body,
                fuelType: fuel,
                transmission: transmission,
              );

              final parsedBudget = double.parse(budgetCtrl.text);

              setState(() {
                price = result;
                budget = parsedBudget;
              });
            },
            child: const Text('Predecir precio'),
          ),

          const SizedBox(height: 14),

          if (price != null)
            Text(
              'Precio estimado: \$${price!.toStringAsFixed(2)} USD',
              style: const TextStyle(fontSize: 18),
            ),

          if (price != null && budget != null) ...[
            const SizedBox(height: 8),
            if (budget! >= price!)
              Text(
                'Sí te alcanza. Te sobran: \$${(budget! - price!).toStringAsFixed(2)} USD',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9CFF9C),
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'No te alcanza. Te faltan: \$${(price! - budget!).toStringAsFixed(2)} USD para comprar el carro deseado.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFFFB3B3),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
