
import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:ecotrack_meta/dominio/meta.dart';
import 'package:flutter/foundation.dart';

class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this._repositorio);

  final ConsumoRepository _repositorio;

  List<Consumo> consumos = [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  double get total =>
      consumos.fold(0.0, (suma, consumo) => suma + consumo.litros);

  double get avance => avanceDeMeta(total: total, meta: meta);

  bool get metaSuperada => total > meta;

  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    final litros = double.tryParse(
      litrosTexto.trim().replaceAll(',', '.'),
    );

    final motivo = validarLitros(litros);

    if (motivo != null) {
      error = motivo;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      await _repositorio.guardar(
        Consumo(
          laboratorio: laboratorio,
          litros: litros!,
        ),
      );

      consumos = await _repositorio.todos();
      return true;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}
