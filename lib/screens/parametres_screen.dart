import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dimdim_belote_helper/models/etat_jeu.dart';
import 'package:dimdim_belote_helper/models/position.dart';
import 'package:dimdim_belote_helper/screens/distribution_screen.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  ConditionFin _conditionFin = ConditionFin.points;
  int _valeurFin = 1000;
  Position _positionJoueur = Position.sud;
  SensRotation _sensRotation = SensRotation.horaire;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de la partie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Condition de fin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<ConditionFin>(
                      title: const Text('Points'),
                      value: ConditionFin.points,
                      groupValue: _conditionFin,
                      onChanged: (value) {
                        setState(() {
                          _conditionFin = value!;
                          _valeurFin = 1000;
                        });
                      },
                    ),
                    RadioListTile<ConditionFin>(
                      title: const Text('Nombre de plis'),
                      value: ConditionFin.plis,
                      groupValue: _conditionFin,
                      onChanged: (value) {
                        setState(() {
                          _conditionFin = value!;
                          _valeurFin = 10;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _valeurFin.toString(),
                      decoration: InputDecoration(
                        labelText: _conditionFin == ConditionFin.points
                            ? 'Nombre de points'
                            : 'Nombre de plis',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          if (_conditionFin == ConditionFin.points) {
                            // Points should be reasonable (between 100 and 10000)
                            if (parsed >= 100 && parsed <= 10000) {
                              _valeurFin = parsed;
                            }
                          } else {
                            // Plis should be between 1 and 50
                            if (parsed >= 1 && parsed <= 50) {
                              _valeurFin = parsed;
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre position',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Position>(
                      value: _positionJoueur,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: Position.values
                          .map((position) => DropdownMenuItem(
                                value: position,
                                child: Text(position.nom),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _positionJoueur = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sens de rotation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<SensRotation>(
                      title: const Text('Horaire'),
                      value: SensRotation.horaire,
                      groupValue: _sensRotation,
                      onChanged: (value) {
                        setState(() {
                          _sensRotation = value!;
                        });
                      },
                    ),
                    RadioListTile<SensRotation>(
                      title: const Text('Anti-horaire'),
                      value: SensRotation.antihoraire,
                      groupValue: _sensRotation,
                      onChanged: (value) {
                        setState(() {
                          _sensRotation = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final parametres = ParametresJeu(
                  conditionFin: _conditionFin,
                  valeurFin: _valeurFin,
                  positionJoueur: _positionJoueur,
                  sensRotation: _sensRotation,
                );
                
                context.read<EtatJeu>().definirParametres(parametres);
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DistributionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Commencer',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
