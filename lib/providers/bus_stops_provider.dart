import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStop {
  final String id;
  final String title;
  final LatLng position;
  final String snippet;

  BusStop({
    required this.id,
    required this.title,
    required this.position,
    required this.snippet,
  });
}

class BusStopProvider with ChangeNotifier {
  final List<BusStop> _busStops = [
    BusStop(
      id: 'bs1',
      title: 'South Bus Terminal (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.298333, 123.893366),
    ),
    BusStop(
      id: 'bs2',
      title: 'Salazar Colleges (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.295654, 123.883587),
    ),
    BusStop(
      id: 'bs3',
      title: 'Mambaling Bus Stop (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.290210, 123.874332),
    ),
    BusStop(
      id: 'bs4',
      title: 'CIT University (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.294299391572943, 123.88146357143806),
    ),
    BusStop(
      id: 'bs5',
      title: 'Basak San Nicolas (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.289171267488848, 123.86738259615565),
    ),
    BusStop(
      id: 'bs6',
      title: 'Bulacao Pardo (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.275899225104547, 123.85178489045964),
    ),
    BusStop(
      id: 'bs7',
      title: 'Easy Visayan Academy (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.27077836678189, 123.84588264580083),
    ),
    BusStop(
      id: 'bs8',
      title: 'Holy Rosary (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.279466791369467, 123.85515380352427),
    ),
    BusStop(
      id: 'bs9',
      title: 'St. Joseph the Worker Parish (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.262377899061319, 123.83816944133557),
    ),
    BusStop(
      id: 'bs10',
      title: 'Robinsons Supermarket (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.25946616173296, 123.82988876484957),
    ),
    BusStop(
      id: 'bs11',
      title: 'Don Bosco Formation (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.259168762261014, 123.82800771126692),
    ),
    BusStop(
      id: 'bs12',
      title: 'Auto Gas (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.25801965427768, 123.81868186355264),
    ),
    BusStop(
      id: 'bs13',
      title: 'MG gateway Cebu South (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.255542263116874, 123.81151426737269),
    ),
    BusStop(
      id: 'bs14',
      title: 'Motorista Motors (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.252307663610495, 123.80682781098639),
    ),
    BusStop(
      id: 'bs15',
      title: 'Tri-J Marketing (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.248699248117545, 123.8022437625227),
    ),
    BusStop(
      id: 'bs16',
      title: 'Belmont One Supermarket (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.247220447440812, 123.80022410965104),
    ),
    BusStop(
      id: 'bs17',
      title: 'Minglanilla Town plaza (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.245436915494555, 123.79584564428231),
    ),
    BusStop(
      id: 'bs18',
      title: 'Cebu Home and Builders (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.24405054836387, 123.79094949774617),
    ),
    BusStop(
      id: 'bs19',
      title: 'IHM PROPER TUNGHAAN CHAPEL (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.242854232347394, 123.78727309803166),
    ),
    BusStop(
      id: 'bs20',
      title: 'SHELL (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.241939791092069, 123.78530859242997),
    ),
    BusStop(
      id: 'bs21',
      title: 'Mary Our Help Technical Institute for women inc. (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.240396758446991, 123.78219582181339),
    ),
    BusStop(
      id: 'bs22',
      title: 'Inayagan Brgy. Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.236523095768401, 123.77451594312963),
    ),
    BusStop(
      id: 'bs23',
      title: 'Total (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.231592709796892, 123.77006907015478),
    ),
    BusStop(
      id: 'bs24',
      title: 'Tuyuan Brgy. Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.228365404883183, 123.76733545270785),
    ),
    BusStop(
      id: 'bs25',
      title: 'KLC Naga City (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.225559798162255, 123.76477776112897),
    ),
    BusStop(
      id: 'bs26',
      title: 'San Vicente Ferrer Chapel (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.218954832638415, 123.76128301643337),
    ),
    BusStop(
      id: 'bs27',
      title: 'Archdiocese Shrine of St. Francis Assisi (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.208568093298569, 123.75863189709499),
    ),
    BusStop(
      id: 'bs28',
      title: 'Foursquare Gospel Church (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.204203148665822, 123.75465423126916),
    ),
    BusStop(
      id: 'bs29',
      title: 'K-Lift Industrial Corp. (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.20240848158943, 123.75328839601684),
    ),
    BusStop(
      id: 'bs30',
      title: 'Tina-an Brgy. Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.193567887854051, 123.74508144923223),
    ),
    BusStop(
      id: 'bs31',
      title: 'Cebu Stonehill Steel corp. (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.185053171724633, 123.7346650048087),
    ),
    BusStop(
      id: 'bs32',
      title: 'Langtad Brangay Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.183682616652971, 123.73272763239166),
    ),
    BusStop(
      id: 'bs33',
      title: 'Star Oil (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.181410816598616, 123.72926012276714),
    ),
    BusStop(
      id: 'bs34',
      title: 'Ichland Academy (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.1787058160171, 123.72451745600266),
    ),
    BusStop(
      id: 'bs35',
      title: 'Pitalo church (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.176397978652279, 123.72112975795304),
    ),
    BusStop(
      id: 'bs36',
      title: 'Sitio Pasil (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.173740856365793, 123.71858286484157),
    ),
    BusStop(
      id: 'bs37',
      title: 'San fernando Municipal Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.16272763236765, 123.70700243932053),
    ),
    BusStop(
      id: 'bs38',
      title: 'Poblacion Brgy. Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(
        10.159588556713507,
        123.70473600398316,
      ),
    ),
    BusStop(
      id: 'bs39',
      title: 'Balud Brgy. Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(
        10.148288241116441,
        123.69451123633434,
      ),
    ),
    BusStop(
      id: 'bs40',
      title: 'Sangat Brgy. Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(
        10.133309488594659,
        123.68789207640678,
      ),
    ),
    BusStop(
      id: 'bs41',
      title: 'Philhealth -Carcar (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.119600351076079,
        123.67822574193868,
      ),
    ),
    BusStop(
      id: 'bs42',
      title: 'Perrelos Elementary school (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.119600351076079,
        123.67822574193868,
      ),
    ),
    BusStop(
      id: 'bs43',
      title: 'Steel Asia (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.11128383714669,
        123.67130303974795,
      ),
    ),
    BusStop(
      id: 'bs44',
      title: 'Gaisano Grand Mall (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.10827952079982,
        123.6453961888074,
      ),
    ),
    BusStop(
      id: 'bs45',
      title: 'Barcenilla-Alcordo House (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.104938249837154,
        123.64165003187705,
      ),
    ),
    BusStop(
      id: 'bs46',
      title: 'Kyle Gas (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.066194896205348,
        123.6281876882764,
      ),
    ),
    BusStop(
      id: 'bs47',
      title: 'Abugon Brgy. Hall (Sibonga)',
      snippet: 'Sibonga',
      position: const LatLng(
        10.05711046630992,
        123.62556181595059,
      ),
    ),
    BusStop(
      id: 'bs48',
      title: 'Candaguit Brgy. Hall (Sibonga)',
      snippet: 'sibonga',
      position: const LatLng(
        10.042870579840828,
        123.62223091222013,
      ),
    ),
    BusStop(
      id: 'bs49',
      title: 'Sabang Brgy. Hall (Sibonga)',
      snippet: 'Sibonga',
      position: const LatLng(
        10.031575011506082,
        123.6187284016527,
      ),
    ),
    BusStop(
      id: 'bs50',
      title: 'Simpark (Sibonga)',
      snippet: 'Sibonga',
      position: const LatLng(
        10.024085840968894,
        123.61725213398493,
      ),
    ),
    BusStop(
      id: 'bs51',
      title: 'Sibonga Plaza (Sibonga)',
      snippet: 'Sibonga',
      position: const LatLng(
        10.017467450594179,
        123.61998111629613,
      ),
    ),
    BusStop(
      id: 'bs52',
      title: 'Petro Gazz (Sibonga)',
      snippet: 'Sibonga',
      position: const LatLng(
        9.976473493990383,
        123.62192167304373,
      ),
    ),
    BusStop(
      id: 'bs53',
      title: 'Simala Elementary School (Sibonga)',
      snippet: 'Sibonga',
      position: const LatLng(
        9.97188008115317,
        123.62145770453536,
      ),
    ),
    BusStop(
      id: "bs54",
      title: 'Bulasa Brgy. Hall (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.927365307077537,
        123.61670311661807,
      ),
    ),
    BusStop(
      id: 'bs55',
      title: 'Binlod Brgy. Hall (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.915318759577847,
        123.60912808501021,
      ),
    ),
    BusStop(
      id: 'bs56',
      title: 'GD Gas Station (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.890895244870979,
        123.60474093703594,
      ),
    ),
    BusStop(
      id: 'bs57',
      title: 'Petron (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.883862678292255,
        123.60622054141294,
      ),
    ),
    BusStop(
      id: 'bs58',
      title: 'Alegria Multi-purpose cooperative inc. (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.88039299119079,
        123.60503839567535,
      ),
    ),
    BusStop(
      id: 'bs59',
      title: 'Tulic Brgy Hall (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.869467675656274,
        123.58570391993325,
      ),
    ),
    BusStop(
      id: 'bs60',
      title: 'Bogo Brgy Hall (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.88039299119079,
        123.60503839567535,
      ),
    ),
    BusStop(
      id: 'bs61',
      title: 'Talaga Brgy Hall (Argao)',
      snippet: 'Argao',
      position: const LatLng(
        9.849526688596825,
        123.567102305171,
      ),
    ),
    BusStop(
      id: 'bs63',
      title: 'Casay Brgy. Hall (Dalaguete)',
      snippet: 'Dalaguete',
      position: const LatLng(
        9.82412903318063,
        123.55013477566096,
      ),
    ),
    BusStop(
      id: 'bs64',
      title: 'Cawayan Brgy. Hall (Dalaguete)',
      snippet: 'Dalaguete',
      position: const LatLng(
        9.807658288183763,
        123.53494666709464,
      ),
    ),
    BusStop(
      id: 'bs65',
      title: 'Sesante Beach (Dalaguete)',
      snippet: 'Dalaguete',
      position: const LatLng(
        9.781097292270433,
        123.53236811818793,
      ),
    ),
    BusStop(
      id: 'bs66',
      title: 'Dalaguete Public Cemetery (Dalaguete)',
      snippet: 'Dalaguete',
      position: const LatLng(
        9.754046879012758,
        123.5289640747502,
      ),
    ),
    BusStop(
      id: 'bs67',
      title: 'Balud Brgy. Hall (Dalaguete)',
      snippet: 'Dalaguete',
      position: const LatLng(
        9.75207010951615,
        123.52373994555653,
      ),
    ),
    BusStop(
      id: 'bs68',
      title: 'Consolacion Brgy. Hall (Dalaguete)',
      snippet: 'Dalaguete',
      position: const LatLng(
        9.749194621489186,
        123.51603506397028,
      ),
    ),
    BusStop(
      id: 'bs69',
      title: 'Pugalo Brgy. Hall (Alcoy)',
      snippet: 'Alcoy',
      position: const LatLng(
        9.731156903939208,
        123.50874502688286,
      ),
    ),
    BusStop(
      id: 'bs70',
      title: 'Petron (Alcoy)',
      snippet: 'Alcoy',
      position: const LatLng(
        9.727855638985965,
        123.50853970050944,
      ),
    ),
    BusStop(
      id: 'bs71',
      title: 'Pasol Brgy. Hall (Alcoy)',
      snippet: 'Alcoy',
      position: const LatLng(
        9.721148053987884,
        123.50964838981908,
      ),
    ),
    BusStop(
        id: 'bs72',
        title: 'Seaview Moonrise Cafe & restaurant (Alcoy)',
        snippet: 'Alcoy',
        position: const LatLng(
          9.715404410171736,
          123.50910727536241,
        )),
    BusStop(
        id: 'bs73',
        title: 'Alcoy Municipal Hall (Alcoy)',
        snippet: 'Alcoy',
        position: const LatLng(
          9.709002606248307,
          123.50684616851754,
        )),
    BusStop(
        id: 'bs74',
        title: 'Atabay Brangayl Hall (Alcoy)',
        snippet: 'Alcoy',
        position: const LatLng(
          9.698046096363164,
          123.50429572096868,
        )),
    BusStop(
        id: 'bs75',
        title: 'Guiwang Brangay Hall (Alcoy)',
        snippet: 'Alcoy',
        position: const LatLng(
          9.688532442132232,
          123.50381690283247,
        )),
    BusStop(
        id: 'bs76',
        title: 'Tingko (Alcoy)',
        snippet: 'Alcoy',
        position: const LatLng(
          9.683728887671302,
          123.50286626359822,
        )),
    BusStop(
        id: 'bs77',
        title: 'Daan Lungsod Brgy. Hall (Alcoy)',
        snippet: 'Alcoy',
        position: const LatLng(
          9.683728887671302,
          123.50286626359822,
        )),
    BusStop(
        id: 'bs78',
        title: 'El Pardo Brgy. Hall (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.66090186558233,
          123.4945753574012,
        )),
    BusStop(
        id: 'bs79',
        title: 'Eli Rock (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.632191074158065,
          123.48206643743009,
        )),
    BusStop(
        id: 'bs80',
        title: 'Poblacion Brgy. Hall (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.629085026346946,
          123.47990372477226,
        )),
    BusStop(
        id: 'bs81',
        title: 'Boljoon Public Market (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.626437611971959,
          123.47966879954457,
        )),
    BusStop(
        id: 'bs82',
        title: 'Casa De Fiel (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.610293801929371,
          123.47384255075696,
        )),
    BusStop(
        id: 'bs83',
        title: 'Granada Brgy. Hall (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.601916386092107,
          123.47380447878918,
        )),
    BusStop(
        id: 'bs84',
        title: 'San Roque Chapel (Boljoon)',
        snippet: 'Boljoon',
        position: const LatLng(
          9.564558657615047,
          123.46090502317351,
        )),
    BusStop(
        id: 'bs85',
        title: 'Pungtod Cemetery (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.567672368384917,
          123.4637505677673,
        )),
    BusStop(
        id: 'bs86',
        title: 'Pungtod Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.563329181727543,
          123.45884605646873,
        )),
    BusStop(
        id: 'bs87',
        title: 'Nueva Caceres Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.561996850341199,
          123.45730797927133,
        )),
    BusStop(
        id: 'bs88',
        title: 'Bonbon Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.555591199096833,
          123.45296142745774,
        )),
    BusStop(
        id: 'bs89',
        title: 'Looc Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.54552986833529,
          123.44834954323295,
        )),
    BusStop(
        id: 'bs90',
        title: 'Vanz Gas Station (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.530289206737583,
          123.43831947775222,
        )),
    BusStop(
        id: 'bs91',
        title: 'Gaisano Grand (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.526582034780946,
          123.4357048602964,
        )),
    BusStop(
        id: 'bs92',
        title: '7-Eleven (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.52143669567215,
          123.43221465713341,
        )),
    BusStop(
        id: 'bs92',
        title: 'Daanlungsod Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.51260369371678,
          123.4222910991533,
        )),
    BusStop(
        id: 'bs93',
        title: 'Calumpang Brgy. Hall (Oslob) ',
        snippet: 'Oslob',
        position: const LatLng(
          9.50961058477161,
          123.41880401065615,
        )),
    BusStop(
        id: 'bs94',
        title: 'Hagdan Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.50961058477161,
          123.41880401065615,
        )),
    BusStop(
        id: 'bs95',
        title: 'Luka Brgy. Hall (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.47984453420458,
          123.38797178419308,
        )),
    BusStop(
        id: 'bs96',
        title: 'Tumalog Falls (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.476417605087985,
          123.38615520966847,
        )),
    BusStop(
        id: 'bs97',
        title: 'Tan-awan (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.46384484034016,
          123.3792241066126,
        )),
    BusStop(
        id: 'bs98',
        title: 'Mainit port (Oslob)',
        snippet: 'Oslob',
        position: const LatLng(
          9.432035158583162,
          123.35907163155478,
        )),
    BusStop(
        id: 'bs99',
        title: 'Santander Municipall Hall (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.416881804918285,
          123.33517856414892,
        )),
    BusStop(
        id: 'bs100',
        title: 'Looc Brgy. Hall (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.419207828052595,
          123.3187024393111,
        )),
    BusStop(
        id: 'bs101',
        title: 'Santander Bus Stop (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.421715536756373,
          123.30222362333592,
        )),
    BusStop(
        id: 'bs102',
        title: 'Gas & Go (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.447198623406795,
          123.30435984999579,
        )),
    BusStop(
        id: 'bs103',
        title: 'Bato Bus Terminal (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.454354021169785,
          123.30355890147524,
        )),
  ];
  final List<BusStop> _busStopsBarili = [
    BusStop(
      id: 'bsb1',
      title: 'South Bus Terminal (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.298333, 123.893366),
    ),
    BusStop(
      id: 'bsb2',
      title: 'Salazar Colleges (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.295654, 123.883587),
    ),
    BusStop(
      id: 'bsb3',
      title: 'Mambaling Bus Stop (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.290210, 123.874332),
    ),
    BusStop(
      id: 'bsb4',
      title: 'CIT University (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.294299391572943, 123.88146357143806),
    ),
    BusStop(
      id: 'bsb5',
      title: 'Basak San Nicolas (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.289171267488848, 123.86738259615565),
    ),
    BusStop(
      id: 'bsb6',
      title: 'Bulacao Pardo (Cebu)',
      snippet: 'Cebu City',
      position: const LatLng(10.275899225104547, 123.85178489045964),
    ),
    BusStop(
      id: 'bsb7',
      title: 'Easy Visayan Academy (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.27077836678189, 123.84588264580083),
    ),
    BusStop(
      id: 'bsb8',
      title: 'Holy Rosary (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.279466791369467, 123.85515380352427),
    ),
    BusStop(
      id: 'bsb9',
      title: 'St. Joseph the Worker Parish (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.262377899061319, 123.83816944133557),
    ),
    BusStop(
      id: 'bsb10',
      title: 'Robinsons Supermarket (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.25946616173296, 123.82988876484957),
    ),
    BusStop(
      id: 'bsb11',
      title: 'Don Bosco Formation (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.259168762261014, 123.82800771126692),
    ),
    BusStop(
      id: 'bsb12',
      title: 'Auto Gas (Talisay)',
      snippet: 'Talisay City',
      position: const LatLng(10.25801965427768, 123.81868186355264),
    ),
    BusStop(
      id: 'bsb13',
      title: 'MG gateway Cebu South (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.255542263116874, 123.81151426737269),
    ),
    BusStop(
      id: 'bsb14',
      title: 'Motorista Motors (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.252307663610495, 123.80682781098639),
    ),
    BusStop(
      id: 'bsb15',
      title: 'Tri-J Marketing (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.248699248117545, 123.8022437625227),
    ),
    BusStop(
      id: 'bsb16',
      title: 'Belmont One Supermarket (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.247220447440812, 123.80022410965104),
    ),
    BusStop(
      id: 'bsb17',
      title: 'Minglanilla Town plaza (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.245436915494555, 123.79584564428231),
    ),
    BusStop(
      id: 'bsb18',
      title: 'Cebu Home and Builders (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.24405054836387, 123.79094949774617),
    ),
    BusStop(
      id: 'bsb19',
      title: 'IHM PROPER TUNGHAAN CHAPEL (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.242854232347394, 123.78727309803166),
    ),
    BusStop(
      id: 'bsb20',
      title: 'SHELL (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.241939791092069, 123.78530859242997),
    ),
    BusStop(
      id: 'bsb21',
      title: 'Mary Our Help Technical Institute for women inc. (Minglanilla)',
      snippet: 'Minglanilla City',
      position: const LatLng(10.240396758446991, 123.78219582181339),
    ),
    BusStop(
      id: 'bsb22',
      title: 'Inayagan Brgy. Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.236523095768401, 123.77451594312963),
    ),
    BusStop(
      id: 'bsb23',
      title: 'Total (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.231592709796892, 123.77006907015478),
    ),
    BusStop(
      id: 'bsb24',
      title: 'Tuyuan Brgy. Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.228365404883183, 123.76733545270785),
    ),
    BusStop(
      id: 'bsb25',
      title: 'KLC Naga City (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.225559798162255, 123.76477776112897),
    ),
    BusStop(
      id: 'bsb26',
      title: 'San Vicente Ferrer Chapel (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.218954832638415, 123.76128301643337),
    ),
    BusStop(
      id: 'bsb27',
      title: 'Archdiocese Shrine of St. Francis Assisi (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.208568093298569, 123.75863189709499),
    ),
    BusStop(
      id: 'bsb28',
      title: 'Foursquare Gospel Church (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.204203148665822, 123.75465423126916),
    ),
    BusStop(
      id: 'bsb29',
      title: 'K-Lift Industrial Corp. (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.20240848158943, 123.75328839601684),
    ),
    BusStop(
      id: 'bsb30',
      title: 'Tina-an Brgy. Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.193567887854051, 123.74508144923223),
    ),
    BusStop(
      id: 'bsb31',
      title: 'Cebu Stonehill Steel corp. (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.185053171724633, 123.7346650048087),
    ),
    BusStop(
      id: 'bsb32',
      title: 'Langtad Brangay Hall (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.183682616652971, 123.73272763239166),
    ),
    BusStop(
      id: 'bsb33',
      title: 'Star Oil (Naga)',
      snippet: 'Naga City',
      position: const LatLng(10.181410816598616, 123.72926012276714),
    ),
    BusStop(
      id: 'bsb34',
      title: 'Ichland Academy (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.1787058160171, 123.72451745600266),
    ),
    BusStop(
      id: 'bsb35',
      title: 'Pitalo church (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.176397978652279, 123.72112975795304),
    ),
    BusStop(
      id: 'bsb36',
      title: 'Sitio Pasil (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.173740856365793, 123.71858286484157),
    ),
    BusStop(
      id: 'bsb37',
      title: 'San fernando Municipal Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(10.16272763236765, 123.70700243932053),
    ),
    BusStop(
      id: 'bsb38',
      title: 'Poblacion Brgy. Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(
        10.159588556713507,
        123.70473600398316,
      ),
    ),
    BusStop(
      id: 'bsb39',
      title: 'Balud Brgy. Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(
        10.148288241116441,
        123.69451123633434,
      ),
    ),
    BusStop(
      id: 'bsb40',
      title: 'Sangat Brgy. Hall (San Fernando)',
      snippet: 'San Fernando',
      position: const LatLng(
        10.133309488594659,
        123.68789207640678,
      ),
    ),
    BusStop(
      id: 'bsb41',
      title: 'Philhealth -Carcar (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.119600351076079,
        123.67822574193868,
      ),
    ),
    BusStop(
      id: 'bsb42',
      title: 'Perrelos Elementary school (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.119600351076079,
        123.67822574193868,
      ),
    ),
    BusStop(
      id: 'bsb43',
      title: 'Steel Asia (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.11128383714669,
        123.67130303974795,
      ),
    ),
    BusStop(
      id: 'bsb44',
      title: 'Gaisano Grand Mall (Carcar)',
      snippet: 'Carcar',
      position: const LatLng(
        10.10827952079982,
        123.6453961888074,
      ),
    ),
    BusStop(
        id: 'bsb45',
        title: 'Guadalupe Brgy. Hall (Carcar)',
        snippet: 'Carcar',
        position: const LatLng(
          10.10942671653251,
          123.60723232179032,
        )),
    BusStop(
        id: 'bsb46',
        title: 'Mantalungon Public Market (Carcar)',
        snippet: 'Carcar',
        position: const LatLng(
          10.126585767935298,
          123.5807935198908,
        )),
    BusStop(
        id: 'bsb47',
        title: 'Tubod Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.11671301203523,
          123.56659720025803,
        )),
    BusStop(
        id: 'bsb48',
        title: 'Dakit Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.114291138558793,
          123.55417400544039,
        )),
    BusStop(
        id: 'bsb49',
        title: 'Patupat Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.128078173096169,
          123.52950301354414,
        )),
    BusStop(
        id: 'bsb50',
        title: 'Azucenat Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.123470033806102,
          123.52249815434539,
        )),
    BusStop(
        id: 'bsb51',
        title: 'Santa Ana Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.117111572264832,
          123.51294056992921,
        )),
    BusStop(
        id: 'bsb52',
        title: 'Shamrock Bus Station (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.117111572264832,
          123.51294056992921,
        )),
    BusStop(
        id: 'bsb53',
        title: 'Sayaw Brgy. Hall ((Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.111710057662885,
          123.47959777986227,
        )),
    BusStop(
        id: 'bsb54',
        title: 'Minolos Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.103298678265267,
          123.47350370234724,
        )),
    BusStop(
        id: 'bsb55',
        title: 'Guiwanon Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.098012303698264,
          123.47034728525638,
        )),
    BusStop(
        id: 'bsb56',
        title: 'Kanyuko Brgy. Hall (Barili)',
        snippet: 'Barili',
        position: const LatLng(
          10.091530613814308,
          123.4647517827578,
        )),
    BusStop(
        id: 'bsb57',
        title: 'Bitoon Brgy. Hall (Dumanjug)',
        snippet: 'Dumanjug',
        position: const LatLng(
          10.080644198958757,
          123.4557716452177,
        )),
    BusStop(
        id: 'bsb58',
        title: 'Tapon Brgy. Hall (Dumanjug)',
        snippet: 'Dumanjug',
        position: const LatLng(
          10.063337149780805,
          123.44488473993185,
        )),
    BusStop(
        id: 'bsb59',
        title: 'Dumanjug Public Market (Dumanjug)',
        snippet: 'Dumanjug',
        position: const LatLng(
          10.057788699165807,
          123.4363655556053,
        )),
    BusStop(
        id: 'bsb60',
        title: 'Li-ong Brgy Hall (Dumanjug)',
        snippet: 'Dumanjug',
        position: const LatLng(
          10.044366853179733,
          123.4293347733383,
        )),
    BusStop(
        id: 'bsb61',
        title: 'San Isidro Labrador Chapel (Ronda)',
        snippet: 'Ronda',
        position: const LatLng(
          10.014840132049192,
          123.41437191180339,
        )),
    BusStop(
        id: 'bsb62',
        title: 'Canduling Brgy. Hall (Ronda)',
        snippet: 'Ronda',
        position: const LatLng(
          10.008118017056987,
          123.41364065723364,
        )),
    BusStop(
        id: 'bsb63',
        title: 'Palanas Brgy. Hall (Ronda)',
        snippet: 'Ronda',
        position: const LatLng(
          9.993404594370318,
          123.40765404201748,
        )),
    BusStop(
        id: 'bsb64',
        title: 'Iglesia ni Cristo (Alcantara)',
        snippet: 'Alcantara',
        position: const LatLng(
          9.97892681377006,
          123.40531018618448,
        )),
    BusStop(
        id: 'bsb65',
        title: 'Alcantara Central Elementary School (Alcantara)',
        snippet: 'Alcantara',
        position: const LatLng(
          9.974369804830827,
          123.40538008368323,
        )),
    BusStop(
        id: 'bsb66',
        title: 'Fly oil (Alcantara)',
        snippet: 'Alcantara',
        position: const LatLng(
          9.971227985669412,
          123.40482820845993,
        )),
    BusStop(
        id: 'bsb67',
        title: 'Saint Agustine Academy (Alcantara)',
        snippet: 'Alcantara',
        position: const LatLng(
          9.966768652042013,
          123.40273127498342,
        )),
    BusStop(
        id: 'bsb68',
        title: 'Lola Alcantara Lot (Moalboal)',
        snippet: 'Moalboal',
        position: const LatLng(
          9.959967974356529,
          123.40144345158329,
        )),
    BusStop(
        id: 'bsb69',
        title: 'Tunga Brgy Hall (Moalboal)',
        snippet: 'Moalboal',
        position: const LatLng(
          9.952447333644168,
          123.40053837950109,
        )),
    BusStop(
        id: 'bsb70',
        title: 'Gaisano Grand Mall (Moalboal)',
        snippet: 'Moalboal',
        position: const LatLng(
          9.943659362355781,
          123.3963094122089,
        )),
    BusStop(
        id: 'bsb71',
        title: 'Bitoon Elementary School (Moalboal)',
        snippet: 'Moalboal',
        position: const LatLng(
          9.900890203585528,
          123.4048754178991,
        )),
    BusStop(
        id: 'bsb72',
        title: 'Malhiao Brgy. Hall (Badian)',
        snippet: 'Badian',
        position: const LatLng(
          9.882733667258325,
          123.40163774886643,
        )),
    BusStop(
        id: 'bsb73',
        title: 'Badian Sports Complex (Badian)',
        snippet: 'Badian',
        position: const LatLng(
          9.869205198840907,
          123.39619950989525,
        )),
    BusStop(
        id: 'bsb74',
        title: 'kawasan Falls (Badian)',
        snippet: 'Badian',
        position: const LatLng(
          9.866583518186602,
          123.39405411435189,
        )),
    BusStop(
        id: 'bsb75',
        title: 'Banhigan Public market (Badian)',
        snippet: 'Badian',
        position: const LatLng(
          9.842865848421209,
          123.38407019579267,
        )),
    BusStop(
        id: 'bsb76',
        title: 'Malabago Brgy. Hall (Badian)',
        snippet: 'Badian',
        position: const LatLng(
          9.825649232450452,
          123.37365211649852,
        )),
    BusStop(
        id: 'bsb77',
        title: 'Beltram Canyyoneering (Badian)',
        snippet: 'Badian',
        position: const LatLng(
          9.816284563278563,
          123.37187340142498,
        )),
    BusStop(
        id: 'bsb78',
        title: 'Kawasan falls Bus Stop (Alegria)',
        snippet: 'Alegria',
        position: const LatLng(
          9.80985315873355,
          123.36644822114032,
        )),
    BusStop(
        id: 'bsb79',
        title: 'Madidejos Brgy. Hall (Alegria)',
        snippet: 'Alegria',
        position: const LatLng(
          9.789045499905162,
          123.35228912269034,
        )),
    BusStop(
        id: 'bsb80',
        title: 'Santa Filomena National High School (Alegria)',
        snippet: 'Alegria',
        position: const LatLng(
          9.762772973373288,
          123.345326548914,
        )),
    BusStop(
        id: 'bsb81',
        title: 'Santa Filomena Brgy. Hall (Alegria)',
        snippet: 'Alegria',
        position: const LatLng(
          9.751512776598176,
          123.34238103994262,
        )),
    BusStop(
        id: 'bsb82',
        title: 'Alegria Municipal Hall (Alegria)',
        snippet: 'Alegria',
        position: const LatLng(
          9.729464160699457,
          123.34015214392475,
        )),
    BusStop(
        id: 'bsb83',
        title: 'PTT Gasoline Station (Alegria)',
        snippet: 'Alegria',
        position: const LatLng(
          9.724890967612305,
          123.3399476397211,
        )),
    BusStop(
        id: 'bsb84',
        title: 'Legaspi Brgy. Hall (Malabuyoc)',
        snippet: 'Malabuyoc',
        position: const LatLng(
          9.710164996527748,
          123.33698630609885,
        )),
    BusStop(
        id: 'bsb85',
        title: 'San Roque Chapel (Malabuyoc)',
        snippet: 'Malabuyoc',
        position: const LatLng(
          9.685123494644468,
          123.32893766823635,
        )),
    BusStop(
        id: 'bsb86',
        title: 'Dos Ojos Beach Park (Malabuyoc)',
        snippet: 'Malabuyoc',
        position: const LatLng(
          9.663301145157599,
          123.32460666568191,
        )),
    BusStop(
        id: 'bsb87',
        title: 'Malabuyoc Municipal Hall (Malabuyoc)',
        snippet: 'Malabuyoc',
        position: const LatLng(
          9.656497093025742,
          123.32551731747243,
        )),
    BusStop(
        id: 'bsb88',
        title: 'Looc Brgy. Hall (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.617486006221936,
          123.32117457643554,
        )),
    BusStop(
        id: 'bsb89',
        title: 'Kabotogan Falls (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.602942707302454,
          123.31854063992627,
        )),
    BusStop(
        id: 'bsb90',
        title: 'Guiwanon Brgy. Hall (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.588978943354192,
          123.31663854969987,
        )),
    BusStop(
        id: 'bsb91',
        title: 'Ginatilan Cemetery (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.575326692067115,
          123.31531642949044,
        )),
    BusStop(
        id: 'bsb92',
        title: 'Holy Trinity College Inc. (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.568905687540708,
          123.3128422063071,
        )),
    BusStop(
        id: 'bsb93',
        title: 'Ginatilan Integrated School (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.563896690831491,
          123.31089268384954,
        )),
    BusStop(
        id: 'bsb94',
        title: 'Palanas brgy. Hall (Ginatilan)',
        snippet: 'Ginatilan',
        position: const LatLng(
          9.563896690831491,
          123.31089268384954,
        )),
    BusStop(
        id: 'bsb95',
        title: 'NGCP Suba Cable Terminal Station (Samboan)',
        snippet: 'Samboan',
        position: const LatLng(
          9.550988152686655,
          123.30751278570186,
        )),
    BusStop(
        id: 'bsb96',
        title: 'Samboan Municipal Hall (Samboan)',
        snippet: 'Samboan',
        position: const LatLng(
          9.52854829139143,
          123.30635139462578,
        )),
    BusStop(
        id: 'bsb97',
        title: 'Pantalan Of Tiltil (Samboan)',
        snippet: 'Samboan',
        position: const LatLng(
          9.517251889454966,
          123.30123218851874,
        )),
    BusStop(
        id: 'bsb98',
        title: 'Bato Samboan Cemetery (Samboan)',
        snippet: 'Samboan',
        position: const LatLng(
          9.475162546696016,
          123.29724077638957,
        )),
    BusStop(
        id: 'bsb99',
        title: 'Bato Port (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.458877634645193,
          123.30144364152176,
        )),
    BusStop(
        id: 'bsb100',
        title: 'Bato Bus Terminal (Santander)',
        snippet: 'Santander',
        position: const LatLng(
          9.454354021169785,
          123.30355890147524,
        )),
  ];

  List<BusStop> get busStops {
    return [..._busStops];
  }

  BusStop? getBusStopByTitle(String title) {
    return _busStops.firstWhere((busStop) => busStop.title == title);
  }

  List<BusStop> get busStopsBarili {
    return [..._busStopsBarili];
  }

  BusStop? getBusStopBariliByTitle(String title) {
    return _busStopsBarili
        .firstWhere((busStopsBarili) => busStopsBarili.title == title);
  }
}
