# 🚀 plugin_wifi_connect

[![pub package](https://img.shields.io/pub/v/plugin_wifi_connect.svg)](https://pub.dev/packages/plugin_wifi_connect)
[![license](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

**Flutter connector for Wi‑Fi devices**

Low‑dependency plugin to simplify automatic connection to devices via SSID or SSID prefix. Compatible with **Android 10+ (API 29+)** and **iOS 12+**.

**Conector Flutter para dispositivos Wi‑Fi**

Plugin com baixa dependência para facilitar a conexão automática a dispositivos via SSID ou prefixo de SSID. Compatível com **Android 10+ (API 29+)** e **iOS 12+**.

---

## 💻 Pub Dev / Installation / Instalação

- Pub: https://pub.dev/packages/plugin_wifi_connect

Install from `pub.dev` (recommended):

Instalar via `pub.dev` (recomendado):

```yaml
dependencies:
  plugin_wifi_connect: ^2.0.2
```

Or install directly from the repository (development):

Ou instalar direto do repositório (desenvolvimento):

```yaml
dependencies:
  plugin_wifi_connect:
    git:
      url: https://github.com/chenrilima/plugin_wifi_connect.git
      ref: main
```

Then:

Depois:

```bash
flutter pub get
```

---

## 🎯 Features / Funcionalidades

- ✅ Connects to an exact SSID (iOS 12+, Android).
- 🔍 Connects to SSIDs that match a prefix (iOS 13+, Android).
- 📡 Compatible with IoT devices that use unique SSIDs.
- ⚙️ Efficient strategy on Android: scans and connects by prefix (requires runtime permission `ACCESS_FINE_LOCATION`).

- ✅ Conecta-se a um SSID exato (iOS 12+, Android).
- 🔍 Conecta-se a SSIDs que combinam um prefixo (iOS 13+, Android).
- 📡 Compatível com dispositivos IoT que usam SSIDs únicos.
- ⚙️ Estratégia eficiente no Android: escaneia e conecta por prefixo (requer permissão em tempo de execução `ACCESS_FINE_LOCATION`).

---

## 🔧 Usage / Uso (full example / exemplo completo)

```dart
import 'package:flutter/material.dart';
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(home: HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'idle';

  Future<void> _connectDirect() async {
    try {
      final ok = await PluginWifiConnect.connectToSecureNetwork(
        'MeuDispositivoWiFi',
        'senha123',
      );
      if (!mounted) return;
      setState(() => _status = ok == true ? 'Conectado' : 'Falha ao conectar');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Erro: $e');
    }
  }

  Future<void> _connectPrefix() async {
    try {
      final ok = await PluginWifiConnect.connectToSecureNetworkByPrefix(
        'IoTDevice_',
        'senhaPadrao',
      );
      if (!mounted) return;
      setState(() =>
          _status = ok == true ? 'Conectado por prefixo' : 'Não encontrado');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('plugin_wifi_connect example')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton(
                onPressed: _connectDirect, child: const Text('Conectar SSID')),
            ElevatedButton(
                onPressed: _connectPrefix,
                child: const Text('Conectar por Prefixo')),
            const SizedBox(height: 12),
            Text(_status),
          ]),
        ),
      );
}
```

---

## 📱 Permissions / Notas por plataforma

Android (add to `AndroidManifest.xml`):

Android (adicionar no `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

iOS notes:

- In the consuming app, enable **Hotspot Configuration** and **Access Wi-Fi Information** in Xcode → Signing & Capabilities. The provisioning profile must also include these capabilities.
- The connection uses `NEHotspotConfiguration` (iOS 11+); prefix connections require iOS 13+. WPA3 (`isWpa3`) is an option that only the Android implementation uses.
- Reading the SSID can return `null`, even with the entitlements, when the iOS access conditions are not met. See [Hotspot Configuration](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.hotspotconfiguration) and [fetchCurrent](https://developer.apple.com/documentation/networkextension/nehotspotnetwork/fetchcurrent(completionhandler:)).
- Validate the connection and SSID reading on a physical iPhone; the simulator does not validate real Wi-Fi behaviour.

Notas iOS:

- No aplicativo consumidor, habilite **Hotspot Configuration** e **Access Wi-Fi Information** em Xcode → Signing & Capabilities. O perfil de provisionamento também precisa incluir essas capabilities.
- A conexão usa `NEHotspotConfiguration` (iOS 11+); conexões por prefixo exigem iOS 13+. WPA3 (`isWpa3`) é uma opção usada somente pela implementação Android.
- A leitura do SSID pode retornar `null`, mesmo com os entitlements, quando as condições de acesso do iOS não forem atendidas. Consulte [Hotspot Configuration](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.hotspotconfiguration) e [fetchCurrent](https://developer.apple.com/documentation/networkextension/nehotspotnetwork/fetchcurrent(completionhandler:)).
- Valide conexão e leitura do SSID em um iPhone físico; o simulador não valida o funcionamento real do Wi-Fi.

## Native iOS integration / Integração nativa iOS

The code in this repository supports **CocoaPods and Swift Package Manager**. Check the published version separately; these changes are not published yet.

The plugin declares iOS 12 as its minimum. The Flutter version that the app uses can require a newer iOS. To validate both modes with the example, see [example/README.md](example/README.md).

The connection methods return `bool?`: treat `true` as success and `false`/`null` as an unconfirmed connection. `register()` and `unregister()` currently do not run native operations. The methods `isEnabled`, `activateWifi()` and `deactivateWifi()` have no handlers in the current Android implementation and must not be used as supported operations.

O código neste repositório oferece suporte a **CocoaPods e Swift Package Manager**. A versão publicada deve ser conferida separadamente; estas alterações ainda não foram publicadas.

O mínimo declarado pelo plugin é iOS 12. A versão do Flutter utilizada pelo aplicativo pode exigir um iOS mais recente. Para validar os dois modos com o exemplo, consulte [example/README.md](example/README.md).

Os métodos de conexão retornam `bool?`: trate `true` como sucesso e `false`/`null` como conexão não confirmada. `register()` e `unregister()` atualmente não executam operações nativas. Os métodos `isEnabled`, `activateWifi()` e `deactivateWifi()` não têm handlers na implementação Android atual e não devem ser usados como operações suportadas.

---

## 📚 Links & Contributing / Links & Contribuição

- Example / Exemplo: [example/](example/)
- CHANGELOG: [CHANGELOG.md](CHANGELOG.md)
- Report issues / Reportar problemas: https://github.com/chenrilima/plugin_wifi_connect/issues
- Contributing: open a PR or an issue to discuss changes.
- Contribuição: abra um PR ou issue para discutir mudanças.
