# 🚀 plugin_wifi_connect

[![pub package](https://img.shields.io/pub/v/plugin_wifi_connect.svg)](https://pub.dev/packages/plugin_wifi_connect)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Flutter connector for Wi‑Fi devices**

Low‑dependency plugin to simplify automatic connection to devices via SSID or SSID prefix. Compatible with **Android 10+ (API 29+)** and **iOS 11+**.

**Conector Flutter para dispositivos Wi‑Fi**

Plugin com baixa dependência para facilitar a conexão automática a dispositivos via SSID ou prefixo de SSID. Compatível com **Android 10+ (API 29+)** e **iOS 11+**.

---

## 💻 Pub Dev / Instalação

- Pub: https://pub.dev/packages/plugin_wifi_connect

Instalar via `pub.dev` (recomendado):

```yaml
dependencies:
  plugin_wifi_connect: ^2.0.2
```

Ou instalar direto do repositório (desenvolvimento):

```yaml
dependencies:
  plugin_wifi_connect:
    git:
      url: https://github.com/chenrilima/plugin_wifi_connect.git
      ref: main
```

Depois:

```bash
flutter pub get
```

---

## 🎯 Features / Funcionalidades

- ✅ Connects to an exact SSID (iOS 11+, Android).
- 🔍 Connects to SSIDs that match a prefix (iOS 13+, Android).
- 📡 Compatible with IoT devices that use unique SSIDs.
- ⚙️ Efficient strategy on Android: scans and connects by prefix (requires runtime permission `ACCESS_FINE_LOCATION`).

- ✅ Conecta-se a um SSID exato (iOS 11+, Android).
- 🔍 Conecta-se a SSIDs que combinam um prefixo (iOS 13+, Android).
- 📡 Compatível com dispositivos IoT que usam SSIDs únicos.
- ⚙️ Estratégia eficiente no Android: escaneia e conecta por prefixo (requer permissão em tempo de execução `ACCESS_FINE_LOCATION`).

---

## 🔧 Usage / Uso (exemplo completo)

```dart
import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'idle';

  Future<void> _connectDirect() async {
    try {
      final ok = await PluginWifiConnect.connectToSsid(
        ssid: 'MeuDispositivoWiFi',
        password: 'senha123',
      );
      setState(() => _status = ok ? 'Conectado' : 'Falha ao conectar');
    } catch (e) {
      setState(() => _status = 'Erro: $e');
    }
  }

  Future<void> _connectPrefix() async {
    final ok = await PluginWifiConnect.connectToSsidPrefix(
      prefix: 'IoTDevice_',
      password: 'senhaPadrao',
    );
    setState(() => _status = ok ? 'Conectado por prefixo' : 'Não encontrado');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('plugin_wifi_connect example')),
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(onPressed: _connectDirect, child: Text('Conectar SSID')),
        ElevatedButton(onPressed: _connectPrefix, child: Text('Conectar por Prefixo')),
        SizedBox(height: 12),
        Text(_status),
      ]),
    ),
  );
}
```

---

## 📱 Permissions / Notas por plataforma

Android (adicionar no `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

Notas iOS:

- Usa `NEHotspotConfiguration` (iOS 11+). Em geral não são necessárias entitlements especiais, mas documente limitações (ex.: redes com captive portal ou redes gerenciadas por MDM podem não funcionar).

---

## 📚 Links & Contribuição

- Example: [example/](example/)
- CHANGELOG: [CHANGELOG.md](CHANGELOG.md)
- Report issues: https://github.com/chenrilima/plugin_wifi_connect/issues
- Contributing: abra um PR ou issue para discutir mudanças.

---

Se quiser, eu posso também abrir um PR com este README ou commitar direto no branch `main`.
