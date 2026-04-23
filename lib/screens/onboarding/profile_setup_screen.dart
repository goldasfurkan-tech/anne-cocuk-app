import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'child_setup_screen.dart';

// Türkiye il/ilçe verisi
const Map<String, List<String>> turkeyData = {
  'Adana': [
    'Aladağ',
    'Ceyhan',
    'Çukurova',
    'Feke',
    'İmamoğlu',
    'Karaisalı',
    'Karataş',
    'Kozan',
    'Pozantı',
    'Saimbeyli',
    'Sarıçam',
    'Seyhan',
    'Tufanbeyli',
    'Yumurtalık',
    'Yüreğir',
  ],
  'Adıyaman': [
    'Adıyaman Merkez',
    'Besni',
    'Çelikhan',
    'Gerger',
    'Gölbaşı',
    'Kahta',
    'Samsat',
    'Sincik',
    'Tut',
  ],
  'Afyonkarahisar': [
    'Afyon Merkez',
    'Başmakçı',
    'Bayat',
    'Bolvadin',
    'Çay',
    'Çobanlar',
    'Dazkırı',
    'Dinar',
    'Emirdağ',
    'Evciler',
    'Hocalar',
    'İhsaniye',
    'İscehisar',
    'Kızılören',
    'Sandıklı',
    'Sinanpaşa',
    'Sultandağı',
    'Şuhut',
  ],
  'Ağrı': [
    'Ağrı Merkez',
    'Diyadin',
    'Doğubayazıt',
    'Eleşkirt',
    'Hamur',
    'Patnos',
    'Taşlıçay',
    'Tutak',
  ],
  'Amasya': [
    'Amasya Merkez',
    'Göynücek',
    'Gümüşhacıköy',
    'Hamamözü',
    'Merzifon',
    'Suluova',
    'Taşova',
  ],
  'Ankara': [
    'Akyurt',
    'Altındağ',
    'Ayaş',
    'Balâ',
    'Beypazarı',
    'Çamlıdere',
    'Çankaya',
    'Çubuk',
    'Elmadağ',
    'Etimesgut',
    'Evren',
    'Gölbaşı',
    'Güdül',
    'Haymana',
    'Kalecik',
    'Kazan',
    'Keçiören',
    'Kızılcahamam',
    'Mamak',
    'Nallıhan',
    'Polatlı',
    'Pursaklar',
    'Sincan',
    'Şereflikoçhisar',
    'Yenimahalle',
  ],
  'Antalya': [
    'Aksu',
    'Alanya',
    'Demre',
    'Döşemealtı',
    'Elmalı',
    'Finike',
    'Gazipaşa',
    'Gündoğmuş',
    'İbradı',
    'Kaş',
    'Kemer',
    'Kepez',
    'Konyaaltı',
    'Korkuteli',
    'Kumluca',
    'Manavgat',
    'Muratpaşa',
    'Serik',
  ],
  'Artvin': [
    'Ardanuç',
    'Arhavi',
    'Artvin Merkez',
    'Borçka',
    'Hopa',
    'Kemalpaşa',
    'Murgul',
    'Şavşat',
    'Yusufeli',
  ],
  'Aydın': [
    'Bozdoğan',
    'Buharkent',
    'Çine',
    'Didim',
    'Efeler',
    'Germencik',
    'İncirliova',
    'Karacasu',
    'Karpuzlu',
    'Koçarlı',
    'Köşk',
    'Kuşadası',
    'Kuyucak',
    'Nazilli',
    'Söke',
    'Sultanhisar',
    'Yenipazar',
  ],
  'Balıkesir': [
    'Altıeylül',
    'Ayvalık',
    'Balya',
    'Bandırma',
    'Bigadiç',
    'Burhaniye',
    'Dursunbey',
    'Edremit',
    'Erdek',
    'Gömeç',
    'Gönen',
    'Havran',
    'İvrindi',
    'Karesi',
    'Kepsut',
    'Manyas',
    'Marmara',
    'Savaştepe',
    'Sındırgı',
    'Susurluk',
  ],
  'Bilecik': [
    'Bilecik Merkez',
    'Bozüyük',
    'Gölpazarı',
    'İnhisar',
    'Osmaneli',
    'Pazaryeri',
    'Söğüt',
    'Yenipazar',
  ],
  'Bingöl': [
    'Adaklı',
    'Bingöl Merkez',
    'Genç',
    'Karlıova',
    'Kiğı',
    'Solhan',
    'Yayladere',
    'Yedisu',
  ],
  'Bitlis': [
    'Adilcevaz',
    'Ahlat',
    'Bitlis Merkez',
    'Güroymak',
    'Hizan',
    'Mutki',
    'Tatvan',
  ],
  'Bolu': [
    'Bolu Merkez',
    'Dörtdivan',
    'Gerede',
    'Göynük',
    'Kıbrıscık',
    'Mengen',
    'Mudurnu',
    'Seben',
    'Yeniçağa',
  ],
  'Burdur': [
    'Ağlasun',
    'Altınyayla',
    'Bucak',
    'Burdur Merkez',
    'Çavdır',
    'Çeltikçi',
    'Gölhisar',
    'Karamanlı',
    'Kemer',
    'Tefenni',
    'Yeşilova',
  ],
  'Bursa': [
    'Büyükorhan',
    'Gemlik',
    'Gürsu',
    'Harmancık',
    'İnegöl',
    'İznik',
    'Karacabey',
    'Keles',
    'Kestel',
    'Mudanya',
    'Mustafakemalpaşa',
    'Nilüfer',
    'Orhaneli',
    'Orhangazi',
    'Osmangazi',
    'Yenişehir',
    'Yıldırım',
  ],
  'Çanakkale': [
    'Ayvacık',
    'Bayramiç',
    'Biga',
    'Bozcaada',
    'Çan',
    'Çanakkale Merkez',
    'Eceabat',
    'Ezine',
    'Gelibolu',
    'Gökçeada',
    'Lapseki',
    'Yenice',
  ],
  'Çankırı': [
    'Atkaracalar',
    'Bayramören',
    'Çankırı Merkez',
    'Eldivan',
    'Ilgaz',
    'Khanköy',
    'Korgun',
    'Kurşunlu',
    'Orta',
    'Şabanözü',
    'Yapraklı',
  ],
  'Çorum': [
    'Alaca',
    'Bayat',
    'Boğazkale',
    'Çorum Merkez',
    'Dodurga',
    'İskilip',
    'Kargı',
    'Laçin',
    'Mecitözü',
    'Oğuzlar',
    'Ortaköy',
    'Osmancık',
    'Sungurlu',
    'Uğurludağ',
  ],
  'Denizli': [
    'Acıpayam',
    'Babadağ',
    'Baklan',
    'Bekilli',
    'Beyağaç',
    'Bozkurt',
    'Buldan',
    'Çal',
    'Çameli',
    'Çardak',
    'Çivril',
    'Güney',
    'Honaz',
    'Kale',
    'Merkezefendi',
    'Pamukkale',
    'Sarayköy',
    'Serinhisar',
    'Tavas',
  ],
  'Diyarbakır': [
    'Bağlar',
    'Bismil',
    'Çermik',
    'Çınar',
    'Çüngüş',
    'Dicle',
    'Eğil',
    'Ergani',
    'Hani',
    'Hazro',
    'Kayapınar',
    'Kocaköy',
    'Kulp',
    'Lice',
    'Silvan',
    'Sur',
    'Yenişehir',
  ],
  'Edirne': [
    'Edirne Merkez',
    'Enez',
    'Havsa',
    'İpsala',
    'Keşan',
    'Lalapaşa',
    'Meriç',
    'Süloğlu',
    'Uzunköprü',
  ],
  'Elazığ': [
    'Ağın',
    'Alacakaya',
    'Arıcak',
    'Baskil',
    'Elazığ Merkez',
    'Karakoçan',
    'Keban',
    'Kovancılar',
    'Maden',
    'Palu',
    'Sivrice',
  ],
  'Erzincan': [
    'Çayırlı',
    'Erzincan Merkez',
    'İliç',
    'Kemah',
    'Kemaliye',
    'Otlukbeli',
    'Refahiye',
    'Tercan',
    'Üzümlü',
  ],
  'Erzurum': [
    'Aşkale',
    'Aziziye',
    'Çat',
    'Hınıs',
    'Horasan',
    'İspir',
    'Karaçoban',
    'Karayazı',
    'Köprüköy',
    'Narman',
    'Oltu',
    'Olur',
    'Palandöken',
    'Pasinler',
    'Pazaryolu',
    'Şenkaya',
    'Tekman',
    'Tortum',
    'Uzundere',
    'Yakutiye',
  ],
  'Eskişehir': [
    'Alpu',
    'Beylikova',
    'Çifteler',
    'Günyüzü',
    'Han',
    'İnönü',
    'Mahmudiye',
    'Mihalgazi',
    'Mihalıççık',
    'Odunpazarı',
    'Sarıcakaya',
    'Seyitgazi',
    'Sivrihisar',
    'Tepebaşı',
  ],
  'Gaziantep': [
    'Araban',
    'İslahiye',
    'Karkamış',
    'Nizip',
    'Nurdağı',
    'Oğuzeli',
    'Şahinbey',
    'Şehitkamil',
    'Yavuzeli',
  ],
  'Giresun': [
    'Alucra',
    'Bulancak',
    'Çamoluk',
    'Çanakçı',
    'Dereli',
    'Doğankent',
    'Espiye',
    'Eynesil',
    'Giresun Merkez',
    'Görele',
    'Güce',
    'Keşap',
    'Piraziz',
    'Şebinkarahisar',
    'Tirebolu',
    'Yağlıdere',
  ],
  'Gümüşhane': [
    'Gümüşhane Merkez',
    'Kelkit',
    'Köse',
    'Kürtün',
    'Şiran',
    'Torul',
  ],
  'Hakkari': ['Çukurca', 'Hakkari Merkez', 'Şemdinli', 'Yüksekova'],
  'Hatay': [
    'Altınözü',
    'Antakya',
    'Arsuz',
    'Belen',
    'Defne',
    'Dörtyol',
    'Erzin',
    'Hassa',
    'İskenderun',
    'Kırıkhan',
    'Kumlu',
    'Payas',
    'Reyhanlı',
    'Samandağ',
    'Yayladağı',
  ],
  'Iğdır': ['Aralık', 'Iğdır Merkez', 'Karakoyunlu', 'Tuzluca'],
  'Isparta': [
    'Aksu',
    'Atabey',
    'Eğirdir',
    'Gelendost',
    'Gönen',
    'Keçiborlu',
    'Isparta Merkez',
    'Senirkent',
    'Sütçüler',
    'Şarkikaraağaç',
    'Uluborlu',
    'Yalvaç',
    'Yenişarbademli',
  ],
  'İstanbul': [
    'Adalar',
    'Arnavutköy',
    'Ataşehir',
    'Avcılar',
    'Bağcılar',
    'Bahçelievler',
    'Bakırköy',
    'Başakşehir',
    'Bayrampaşa',
    'Beşiktaş',
    'Beykoz',
    'Beylikdüzü',
    'Beyoğlu',
    'Büyükçekmece',
    'Çatalca',
    'Çekmeköy',
    'Esenler',
    'Esenyurt',
    'Eyüpsultan',
    'Fatih',
    'Gaziosmanpaşa',
    'Güngören',
    'Kadıköy',
    'Kağıthane',
    'Kartal',
    'Küçükçekmece',
    'Maltepe',
    'Pendik',
    'Sancaktepe',
    'Sarıyer',
    'Silivri',
    'Sultanbeyli',
    'Sultangazi',
    'Şile',
    'Şişli',
    'Tuzla',
    'Ümraniye',
    'Üsküdar',
    'Zeytinburnu',
  ],
  'İzmir': [
    'Aliağa',
    'Balçova',
    'Bayındır',
    'Bayraklı',
    'Bergama',
    'Beydağ',
    'Bornova',
    'Buca',
    'Çeşme',
    'Çiğli',
    'Dikili',
    'Foça',
    'Gaziemir',
    'Güzelbahçe',
    'Karabağlar',
    'Karaburun',
    'Karşıyaka',
    'Kemalpaşa',
    'Kınık',
    'Kiraz',
    'Konak',
    'Menderes',
    'Menemen',
    'Narlıdere',
    'Ödemiş',
    'Seferihisar',
    'Selçuk',
    'Tire',
    'Torbalı',
    'Urla',
  ],
  'Kahramanmaraş': [
    'Afşin',
    'Andırın',
    'Çağlayancerit',
    'Dulkadiroğlu',
    'Ekinözü',
    'Elbistan',
    'Göksun',
    'Nurhak',
    'Onikişubat',
    'Pazarcık',
    'Türkoğlu',
  ],
  'Karabük': [
    'Eflani',
    'Eskipazar',
    'Karabük Merkez',
    'Ovacık',
    'Safranbolu',
    'Yenice',
  ],
  'Karaman': [
    'Ayrancı',
    'Başyayla',
    'Ermenek',
    'Karaman Merkez',
    'Kazımkarabekir',
    'Sarıveliler',
  ],
  'Kars': [
    'Akyaka',
    'Arpaçay',
    'Digor',
    'Kağızman',
    'Kars Merkez',
    'Sarıkamış',
    'Selim',
    'Susuz',
  ],
  'Kastamonu': [
    'Abana',
    'Ağlı',
    'Araç',
    'Azdavay',
    'Bozkurt',
    'Cide',
    'Çatalzeytin',
    'Daday',
    'Devrekani',
    'Doğanyurt',
    'Hanönü',
    'İhsangazi',
    'İnebolu',
    'Kastamonu Merkez',
    'Küre',
    'Pınarbaşı',
    'Seydiler',
    'Şenpazar',
    'Taşköprü',
    'Tosya',
  ],
  'Kayseri': [
    'Akkışla',
    'Bünyan',
    'Develi',
    'Felahiye',
    'Hacılar',
    'İncesu',
    'Kocasinan',
    'Melikgazi',
    'Özvatan',
    'Pınarbaşı',
    'Sarıoğlan',
    'Sarız',
    'Talas',
    'Tomarza',
    'Yahyalı',
    'Yeşilhisar',
  ],
  'Kırıkkale': [
    'Bahşili',
    'Balışeyh',
    'Çelebi',
    'Delice',
    'Karakeçili',
    'Keskin',
    'Kırıkkale Merkez',
    'Sulakyurt',
    'Yahşihan',
  ],
  'Kırklareli': [
    'Babaeski',
    'Demirköy',
    'Kırklareli Merkez',
    'Kofçaz',
    'Lüleburgaz',
    'Pehlivanköy',
    'Pınarhisar',
    'Vize',
  ],
  'Kırşehir': [
    'Akçakent',
    'Akpınar',
    'Boztepe',
    'Çiçekdağı',
    'Kaman',
    'Kırşehir Merkez',
    'Mucur',
  ],
  'Kilis': ['Elbeyli', 'Kilis Merkez', 'Musabeyli', 'Polateli'],
  'Kocaeli': [
    'Başiskele',
    'Çayırova',
    'Darıca',
    'Derince',
    'Dilovası',
    'Gebze',
    'Gölcük',
    'İzmit',
    'Kandıra',
    'Karamürsel',
    'Kartepe',
    'Körfez',
  ],
  'Konya': [
    'Ahırlı',
    'Akören',
    'Akşehir',
    'Altınekin',
    'Beyşehir',
    'Bozkır',
    'Cihanbeyli',
    'Çeltik',
    'Çumra',
    'Derbent',
    'Derebucak',
    'Doğanhisar',
    'Emirgazi',
    'Ereğli',
    'Güneysınır',
    'Hadim',
    'Halkapınar',
    'Hüyük',
    'Ilgın',
    'Kadınhanı',
    'Karapınar',
    'Karatay',
    'Kulu',
    'Meram',
    'Sarayönü',
    'Selçuklu',
    'Seydişehir',
    'Taşkent',
    'Tuzlukçu',
    'Yalıhüyük',
    'Yunak',
  ],
  'Kütahya': [
    'Altıntaş',
    'Aslanapa',
    'Çavdarhisar',
    'Domaniç',
    'Dumlupınar',
    'Emet',
    'Gediz',
    'Hisarcık',
    'Kütahya Merkez',
    'Pazarlar',
    'Simav',
    'Şaphane',
    'Tavşanlı',
  ],
  'Malatya': [
    'Akçadağ',
    'Arapgir',
    'Arguvan',
    'Battalgazi',
    'Darende',
    'Doğanşehir',
    'Doğanyol',
    'Hekimhan',
    'Kale',
    'Kuluncak',
    'Pütürge',
    'Yazıhan',
    'Yeşilyurt',
  ],
  'Manisa': [
    'Ahmetli',
    'Akhisar',
    'Alaşehir',
    'Demirci',
    'Gölmarmara',
    'Gördes',
    'Kırkağaç',
    'Köprübaşı',
    'Kula',
    'Salihli',
    'Sarıgöl',
    'Saruhanlı',
    'Selendi',
    'Soma',
    'Şehzadeler',
    'Turgutlu',
    'Yunusemre',
  ],
  'Mardin': [
    'Artuklu',
    'Dargeçit',
    'Derik',
    'Kızıltepe',
    'Mazıdağı',
    'Midyat',
    'Nusaybin',
    'Ömerli',
    'Savur',
    'Yeşilli',
  ],
  'Mersin': [
    'Akdeniz',
    'Anamur',
    'Aydıncık',
    'Bozyazı',
    'Çamlıyayla',
    'Erdemli',
    'Gülnar',
    'Mezitli',
    'Mut',
    'Silifke',
    'Tarsus',
    'Toroslar',
    'Yenişehir',
  ],
  'Muğla': [
    'Bodrum',
    'Dalaman',
    'Datça',
    'Fethiye',
    'Kavaklıdere',
    'Köyceğiz',
    'Marmaris',
    'Menteşe',
    'Milas',
    'Ortaca',
    'Seydikemer',
    'Ula',
    'Yatağan',
  ],
  'Muş': ['Bulanık', 'Hasköy', 'Korkut', 'Malazgirt', 'Muş Merkez', 'Varto'],
  'Nevşehir': [
    'Acıgöl',
    'Avanos',
    'Derinkuyu',
    'Gülşehir',
    'Hacıbektaş',
    'Kozaklı',
    'Nevşehir Merkez',
    'Ürgüp',
  ],
  'Niğde': [
    'Altunhisar',
    'Bor',
    'Çamardı',
    'Çiftlik',
    'Niğde Merkez',
    'Ulukışla',
  ],
  'Ordu': [
    'Akkuş',
    'Altınordu',
    'Aybastı',
    'Çamaş',
    'Çatalpınar',
    'Çaybaşı',
    'Fatsa',
    'Gölköy',
    'Gülyalı',
    'Gürgentepe',
    'İkizce',
    'Kabadüz',
    'Kabataş',
    'Korgan',
    'Kumru',
    'Mesudiye',
    'Perşembe',
    'Ulubey',
    'Ünye',
  ],
  'Osmaniye': [
    'Bahçe',
    'Düziçi',
    'Hasanbeyli',
    'Kadirli',
    'Osmaniye Merkez',
    'Sumbas',
    'Toprakkale',
  ],
  'Rize': [
    'Ardeşen',
    'Çamlıhemşin',
    'Çayeli',
    'Derepazarı',
    'Fındıklı',
    'Güneysu',
    'Hemşin',
    'İkizdere',
    'İyidere',
    'Kalkandere',
    'Pazar',
    'Rize Merkez',
  ],
  'Sakarya': [
    'Adapazarı',
    'Akyazı',
    'Arifiye',
    'Erenler',
    'Ferizli',
    'Geyve',
    'Hendek',
    'Karapürçek',
    'Karasu',
    'Kaynarca',
    'Kocaali',
    'Mithatpaşa',
    'Pamukova',
    'Sapanca',
    'Serdivan',
    'Söğütlü',
    'Taraklı',
  ],
  'Samsun': [
    'Alaçam',
    'Asarcık',
    'Atakum',
    'Ayvacık',
    'Bafra',
    'Canik',
    'Çarşamba',
    'Havza',
    'İlkadım',
    'Kavak',
    'Ladik',
    'Ondokuzmayıs',
    'Salıpazarı',
    'Tekkeköy',
    'Terme',
    'Vezirköprü',
    'Yakakent',
  ],
  'Siirt': [
    'Baykan',
    'Eruh',
    'Kurtalan',
    'Pervari',
    'Siirt Merkez',
    'Şirvan',
    'Tillo',
  ],
  'Sinop': [
    'Ayancık',
    'Boyabat',
    'Dikmen',
    'Durağan',
    'Erfelek',
    'Gerze',
    'Saraydüzü',
    'Sinop Merkez',
    'Türkeli',
  ],
  'Sivas': [
    'Akıncılar',
    'Altınyayla',
    'Divriği',
    'Doğanşar',
    'Gemerek',
    'Gölova',
    'Hafik',
    'İmranlı',
    'Kangal',
    'Koyulhisar',
    'Sivas Merkez',
    'Suşehri',
    'Şarkışla',
    'Ulaş',
    'Yıldızeli',
    'Zara',
  ],
  'Şanlıurfa': [
    'Akçakale',
    'Birecik',
    'Bozova',
    'Ceylanpınar',
    'Eyyübiye',
    'Halfeti',
    'Haliliye',
    'Harran',
    'Hilvan',
    'Karaköprü',
    'Siverek',
    'Suruç',
    'Viranşehir',
  ],
  'Şırnak': [
    'Beytüşşebap',
    'Cizre',
    'Güçlükonak',
    'İdil',
    'Silopi',
    'Şırnak Merkez',
    'Uludere',
  ],
  'Tekirdağ': [
    'Çerkezköy',
    'Çorlu',
    'Ergene',
    'Hayrabolu',
    'Kapaklı',
    'Malkara',
    'Marmaraereğlisi',
    'Muratlı',
    'Saray',
    'Süleymanpaşa',
    'Şarköy',
  ],
  'Tokat': [
    'Almus',
    'Artova',
    'Başçiftlik',
    'Erbaa',
    'Niksar',
    'Pazar',
    'Reşadiye',
    'Sulusaray',
    'Tokat Merkez',
    'Turhal',
    'Yeşilyurt',
    'Zile',
  ],
  'Trabzon': [
    'Akçaabat',
    'Araklı',
    'Arsin',
    'Beşikdüzü',
    'Çarşıbaşı',
    'Çaykara',
    'Dernekpazarı',
    'Düzköy',
    'Hayrat',
    'Köprübaşı',
    'Maçka',
    'Of',
    'Ortahisar',
    'Sürmene',
    'Şalpazarı',
    'Tonya',
    'Vakfıkebir',
    'Yomra',
  ],
  'Tunceli': [
    'Çemişgezek',
    'Hozat',
    'Mazgirt',
    'Nazımiye',
    'Ovacık',
    'Pertek',
    'Pülümür',
    'Tunceli Merkez',
  ],
  'Uşak': ['Banaz', 'Eşme', 'Karahallı', 'Sivaslı', 'Ulubey', 'Uşak Merkez'],
  'Van': [
    'Bahçesaray',
    'Başkale',
    'Çaldıran',
    'Çatak',
    'Edremit',
    'Erciş',
    'Gevaş',
    'Gürpınar',
    'İpekyolu',
    'Muradiye',
    'Özalp',
    'Saray',
    'Tuşba',
  ],
  'Yalova': [
    'Altınova',
    'Armutlu',
    'Çınarcık',
    'Çiftlikköy',
    'Termal',
    'Yalova Merkez',
  ],
  'Yozgat': [
    'Akdağmadeni',
    'Aydıncık',
    'Boğazlıyan',
    'Çandır',
    'Çayıralan',
    'Çekerek',
    'Kadışehri',
    'Saraykent',
    'Sarıkaya',
    'Şefaatli',
    'Sorgun',
    'Yenifakılı',
    'Yerköy',
    'Yozgat Merkez',
  ],
  'Zonguldak': [
    'Alaplı',
    'Çaycuma',
    'Devrek',
    'Ereğli',
    'Gökçebey',
    'Kilimli',
    'Kozlu',
    'Zonguldak Merkez',
  ],
};

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  DateTime? _selectedDate;
  String? _photoBase64;
  File? _photoFile;
  bool _isLoading = false;
  String? _selectedCity;
  String? _selectedDistrict;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _photoFile = File(picked.path);
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilemedi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1960),
      lastDate: DateTime(now.year - 18),
      helpText: 'Doğum Tarihin',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğum tarihini seç'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen şehir seç'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ilçe seç'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.firebaseUser!.uid;

    final updatedUser = UserModel(
      uid: uid,
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      phone: authProvider.firebaseUser!.phoneNumber ?? '',
      photoBase64: _photoBase64,
      dateOfBirth: _selectedDate,
      city: _selectedCity,
      district: _selectedDistrict,
      neighborhood: _neighborhoodController.text.trim(),
      createdAt: authProvider.userModel?.createdAt ?? DateTime.now(),
      profileCompleted: false,
    );

    await authProvider.updateUserModel(updatedUser);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final districts = _selectedCity != null
        ? turkeyData[_selectedCity!] ?? []
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Üst başlık
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profilini Tamamla',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Adım 1/2 — Anne Bilgileri',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLight.withOpacity(
                                    0.2,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  image: _photoFile != null
                                      ? DecorationImage(
                                          image: FileImage(_photoFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _photoFile == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Profil fotoğrafı ekle',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),

                      const SizedBox(height: 28),
                      _sectionTitle('Kişisel Bilgiler'),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Ad',
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Adını gir' : null,
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _surnameController,
                        label: 'Soyad',
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Soyadını gir' : null,
                      ),
                      const SizedBox(height: 12),

                      // Doğum tarihi
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.textHint.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null
                                    ? 'Doğum Tarihi Seç'
                                    : DateFormat(
                                        'dd MMMM yyyy',
                                        'tr',
                                      ).format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                      _sectionTitle('Adres Bilgileri'),
                      const SizedBox(height: 12),

                      // Şehir dropdown
                      _buildDropdown(
                        value: _selectedCity,
                        label: 'Şehir Seç',
                        icon: Icons.location_city_outlined,
                        items: turkeyData.keys.toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCity = val;
                            _selectedDistrict = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // İlçe dropdown
                      _buildDropdown(
                        value: _selectedDistrict,
                        label: _selectedCity == null
                            ? 'Önce şehir seç'
                            : 'İlçe Seç',
                        icon: Icons.map_outlined,
                        items: districts,
                        onChanged: _selectedCity == null
                            ? null
                            : (val) {
                                setState(() => _selectedDistrict = val);
                              },
                      ),
                      const SizedBox(height: 12),

                      // Mahalle
                      _buildTextField(
                        controller: _neighborhoodController,
                        label: 'Mahalle',
                        icon: Icons.home_outlined,
                        validator: (v) => v!.isEmpty ? 'Mahallenı gir' : null,
                      ),

                      const SizedBox(height: 32),

                      GradientButton(
                        text: 'Devam Et →',
                        isLoading: _isLoading,
                        onPressed: _saveProfile,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textHint.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textHint.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          selectedItemBuilder: (context) => items
              .map(
                (item) => Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
