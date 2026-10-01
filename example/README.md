# plugin_wifi_connect_example

Exemplo de leitura do SSID usando o plugin local (`path: ../`). Ele não contém uma interface para testar conexões; essas operações precisam ser exercitadas em um aplicativo consumidor de teste.

## Preparação

```bash
flutter pub get
flutter analyze
flutter test
```

Para usar um iPhone, escolha sua equipe de assinatura no Xcode e configure o App ID e o perfil de provisionamento com **Hotspot Configuration** e **Access Wi-Fi Information**. O projeto referencia `Runner/Runner.entitlements` nas configurações Debug, Profile e Release. A presença desses entitlements não garante acesso ao SSID em todas as condições do iOS.

O exemplo declara iOS 11, acompanhando o mínimo do plugin. O Flutter atual pode elevar o mínimo do aplicativo durante a compilação; isso não altera o mínimo declarado pelo plugin.

## Validar CocoaPods

Instale CocoaPods e execute em uma cópia limpa do repositório ou branch de teste:

```bash
flutter config --no-enable-swift-package-manager
cd example
flutter pub get
flutter build ios --simulator --debug
flutter run -d <id-do-iphone>
```

Na raiz do repositório, valide o podspec nas duas configurações:

```bash
pod lib lint ios/plugin_wifi_connect.podspec --configuration=Debug --skip-tests --use-modular-headers --use-libraries
pod lib lint ios/plugin_wifi_connect.podspec --configuration=Debug --skip-tests --use-modular-headers
```

## Validar Swift Package Manager

Use outra cópia limpa para evitar resíduos da integração anterior:

```bash
flutter config --enable-swift-package-manager
cd example
flutter pub get
flutter build ios --simulator --debug
flutter run -d <id-do-iphone>
```

O Flutter migra o projeto Xcode ao ativar SwiftPM. Se avisar que o Podfile precisa de migração manual, na cópia de teste execute `pod deintegrate` em `example/ios`, remova o Podfile e as referências a `Pods/Target Support Files` dos arquivos `Flutter/Debug.xcconfig` e `Flutter/Release.xcconfig`, e tente novamente. Não remova o Podfile da versão compartilhada do exemplo, pois ele permite validar CocoaPods.

Os comandos `flutter config` alteram a preferência global: confira `flutter config --list` antes do teste e restaure a preferência anterior ao terminar. Não inclua arquivos gerados ou migrações temporárias no diff da manutenção.

## Teste funcional em dispositivo físico

- Verificar o SSID conectado e os casos em que retorna `null`.
- Testar `connect` e `connectToSecureNetwork`, incluindo senha inválida e cancelamento.
- Testar `connectByPrefix` e `connectToSecureNetworkByPrefix` no iOS 13+.
- Comparar `saveNetwork: true` e `false` e testar `disconnect`.
- Confirmar o mesmo comportamento com CocoaPods e SwiftPM.

Referência: [guia oficial Flutter para autores de plugins](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors).
