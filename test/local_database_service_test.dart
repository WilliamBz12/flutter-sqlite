import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite_offline/data/services/local_database_service.dart';
import 'package:sqlite_offline/domain/models/task/task.dart';

void main() {
  late LocalDatabaseService databaseService;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Passo 2: Inicializar o banco com o serviço para aplicar o `onUpgrade`
    databaseService = LocalDatabaseService();
    await databaseService.init(inMemory: true);
  });

  tearDown(() async {
    await databaseService.database.close();
  });

  test('Banco inicializa corretamente com inMemoryDatabasePath', () async {
    expect(databaseService.database.isOpen, true);
    expect(await databaseService.database.getVersion(), 3);
  });

  test('Adicionar tarefa ao banco e registrar log', () async {
    final task = Task(
      title: 'Tarefa Teste',
      description: 'Descrição Teste',
      category: 'Trabalho',
      isCompleted: false,
      priority: 1,
    );

    await databaseService.addTask(task);

    final tasks = await databaseService.getTasks();
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Tarefa Teste');

    // Verifica o log de criação
    expect(tasks.first.logs?.length, 1);
    expect(tasks.first.logs?.first.action, 'Criação');
  });

  test('Filtrar tarefas por categoria', () async {
    await databaseService.addTask(Task(
      title: 'Tarefa 1',
      description: 'Descrição 1',
      category: 'Trabalho',
      isCompleted: false,
      priority: 1,
    ));

    await databaseService.addTask(Task(
      title: 'Tarefa 2',
      description: 'Descrição 2',
      category: 'Pessoal',
      isCompleted: true,
      priority: 1,
    ));

    // Filtrar por categoria
    final trabalhoTasks = await databaseService.getTasks(category: 'Trabalho');
    expect(trabalhoTasks.length, 1);
    expect(trabalhoTasks.first.category, 'Trabalho');
  });

  test('Atualizar tarefa e registrar log', () async {
    final taskId = await databaseService.addTask(Task(
      title: 'Tarefa Original',
      description: 'Descrição Original',
      category: 'Trabalho',
      isCompleted: false,
      priority: 1,
    ));

    final updatedTask = Task(
      id: taskId,
      title: 'Tarefa Atualizada',
      description: 'Descrição Atualizada',
      category: 'Trabalho',
      isCompleted: true,
      priority: 1,
    );

    final result = await databaseService.updateTask(updatedTask);
    expect(result, true);

    final tasks = await databaseService.getTasks();
    expect(tasks.first.title, 'Tarefa Atualizada');
    expect(tasks.first.isCompleted, true);

    // Verifica o log de edição
    expect(tasks.first.logs?.length, 2); // Criação + Edição
    expect(tasks.first.logs?.first.action, 'Edição');
  });

  test('Excluir tarefa e registrar log', () async {
    final taskId = await databaseService.addTask(Task(
      title: 'Tarefa Teste',
      description: 'Descrição Teste',
      category: 'Trabalho',
      isCompleted: false,
      priority: 1,
    ));

    final result = await databaseService.deleteTask(taskId);
    expect(result, true);

    final tasks = await databaseService.getTasks();
    expect(tasks.isEmpty, true);
  });
}
