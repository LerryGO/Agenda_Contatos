import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

// id   name    email   phone   img


//Definindo as columas
const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

class ContactHelper {
  //Criando um objeto da esma classe e chamando um construtor interno
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  //Verificando se o banco já foi inicializado
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  //Inicializando o banco de dados
  Future<Database> initDb() async {
    final databasesPath =
        await getDatabasesPath(); //buscando o caminho do banco
    final path = join(databasesPath, "contactsnew.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newer) async {
        await db.execute(
            "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)");
      },
    );
  }

  //Salvando contato
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db; //buscando banco de dados
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  //buscando contato
  Future<Contact> getContact(int id, String email) async {
    Database dbContact = await db; //buscando banco de dados
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ? and $emailColumn like ?",
        whereArgs: [id,email]);
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      // ignore: null_check_always_fails
      return null!;
    }
  }

  //deletando contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //atualizando contato
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db; //buscando banco de dados
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //Obter todos contatos
  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db; //buscando banco de dados
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //Pegando o numero de contatos total
  Future<int?> getNumber() async {
    Database dbContact = await db; //buscando banco de dados
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //Fechando o banco de dados
  Future close() async {
    Database dbContact = await db; //buscando banco de dados
    dbContact.close();
  }
}

//definindo as propriedades da classe Contatos
class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  //Recebendo um mapa com os dados do contato
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  //Conseguir ler nossos contatos
  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img) ";
  }
}
