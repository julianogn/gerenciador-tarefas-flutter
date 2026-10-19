# Gerenciador de Tarefas em Flutter

Aplicativo de tarefas para Android, iOS e Web feito em **Flutter**, organizado com **Clean Architecture**, **DDD**, **MVC**, **design patterns** e **clean code**. As tarefas ficam salvas no próprio aparelho com `shared_preferences`.

Funcionalidades: criar, editar e excluir tarefas; fluxo de status (a fazer, em andamento, concluída); prioridade; prazo com destaque para tarefas atrasadas; filtros e ordenação.

## Como executar

```bash
flutter pub get
flutter run            # escolha um emulador, aparelho ou o Chrome
```

## Qualidade

```bash
flutter analyze
flutter test           # domínio, casos de uso, persistência e widgets
```

## Arquitetura

```
lib/
├── domain/                   # regras de negócio em Dart puro
│   ├── entities/task.dart    # agregado imutável
│   ├── value_objects/        # TaskTitle, Priority, TaskStatus
│   ├── repositories/         # TaskRepository (porta)
│   ├── task_filter.dart      # filtros e ordenações (Strategy)
│   └── failures.dart         # erros de domínio (sealed class)
├── application/
│   └── task_service.dart     # casos de uso
├── infrastructure/           # adaptadores de persistência e mapeamento JSON
├── presentation/
│   ├── controllers/          # TaskController (ChangeNotifier)
│   ├── views/                # páginas
│   └── widgets/              # componentes reutilizáveis
├── app.dart
└── main.dart                 # composition root
```

As dependências apontam para dentro: `presentation → application → domain` e `infrastructure → domain`. O domínio não importa Flutter.

### DDD

- **Agregado** `Task`: imutável; cada mudança (`start`, `complete`, `reopen`, `edit`) devolve uma nova instância e valida as regras.
- **Value Objects**: `TaskTitle` valida a si mesmo; `TaskStatus` conhece a máquina de estados (`canMoveTo`).
- **Repositório**: `TaskRepository` é uma interface do domínio; `SharedPreferencesTaskRepository` e `InMemoryTaskRepository` são implementações.
- **Falhas de domínio** em uma `sealed class`, tratadas pelo controller e mostradas em um `SnackBar`.

### MVC

- **Model**: domínio + `TaskService`.
- **View**: `TaskListPage`, `TaskTile` e `TaskFormSheet`, que só desenham e repassam intenções.
- **Controller**: `TaskController` guarda o estado da tela e chama os casos de uso.

### Design patterns

| Padrão | Onde |
|---|---|
| Repository + Adapter | `TaskRepository` → `SharedPreferencesTaskRepository` |
| Data Mapper | `TaskMapper` (JSON ↔ domínio) |
| Observer | `TaskController extends ChangeNotifier` + `ListenableBuilder` |
| Strategy | `TaskFilter` e `TaskSort` |
| Factory | `Task.create`, `TaskTitle(...)` |
| Immutable Object | `Task` e value objects |
| Dependency Injection | `main.dart` monta tudo; `clock` e `idGenerator` injetáveis nos testes |

### Clean code

- Classes e funções pequenas, com nomes que dizem o que fazem.
- Sem regra de negócio nos widgets: as ações disponíveis vêm de `TaskStatus.canMoveTo`.
- Testes isolados por camada, com relógio e gerador de id controlados.
