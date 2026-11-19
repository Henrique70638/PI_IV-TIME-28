//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'package:flutter/foundation.dart';

//o endereço da api muda dependendo de onde o app roda
String get enderecoApi {
  //navegador roda no proprio computador
  if (kIsWeb) {
    return 'http://localhost:3333/api';
  }
  //no emulador android o computador fica no 10.0.2.2
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3333/api';
  }
  //simulador do iphone usa a rede do mac
  return 'http://localhost:3333/api';
}