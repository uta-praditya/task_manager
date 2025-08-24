# 🏗️ Architecture Documentation

## Clean Architecture Overview

This Task Manager app follows **Clean Architecture** principles with strict layer separation and dependency inversion.

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    Pages    │  │   Widgets   │  │       BLoC          │ │
│  │             │  │             │  │  ┌─────────────────┐ │ │
│  │ • LoginPage │  │ • TaskItem  │  │  │   AuthBloc      │ │ │
│  │ • TaskList  │  │ • TaskStats │  │  │   TaskBloc      │ │ │
│  │ • CreateTask│  │ • FilterChip│  │  └─────────────────┘ │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Entities   │  │  Use Cases  │  │   Repositories      │ │
│  │             │  │             │  │   (Interfaces)      │ │
│  │ • Task      │  │ • GetTasks  │  │                     │ │
│  │ • User      │  │ • CreateTask│  │ • TaskRepository    │ │
│  │ • Project   │  │ • Login     │  │ • AuthRepository    │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Models    │  │ Data Sources│  │   Repositories      │ │
│  │             │  │             │  │ (Implementations)   │ │
│  │ • TaskModel │  │ • Local DB  │  │                     │ │
│  │ • UserModel │  │ • Remote API│  │ • TaskRepoImpl      │ │
│  │             │  │ • Hive      │  │ • AuthRepoImpl      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## State Management Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      BLoC Pattern                           │
│                                                             │
│  UI Event ──► BLoC ──► Use Case ──► Repository ──► Data     │
│     │          │         │            │            │       │
│     │          │         │            │            │       │
│     │          ▼         ▼            ▼            ▼       │
│     │       State ◄── Result ◄─── Data ◄──── Response     │
│     │          │                                           │
│     │          ▼                                           │
│     └──── UI Update                                        │
└─────────────────────────────────────────────────────────────┘
```

## Offline-First Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                   Data Synchronization                      │
│                                                             │
│  ┌─────────────┐           ┌─────────────┐                 │
│  │    UI       │◄─────────►│ Repository  │                 │
│  │             │           │             │                 │
│  └─────────────┘           └─────────────┘                 │
│                                    │                       │
│                            ┌───────┴───────┐               │
│                            │               │               │
│                            ▼               ▼               │
│                   ┌─────────────┐ ┌─────────────┐          │
│                   │ Local Hive  │ │ Remote API  │          │
│                   │ Database    │ │             │          │
│                   └─────────────┘ └─────────────┘          │
│                                                             │
│  Flow:                                                      │
│  1. Always read from Local DB first (immediate response)    │
│  2. Background sync with Remote API when online            │
│  3. Update Local DB with remote data                       │
│  4. UI reflects local data changes                         │
└─────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### 1. **BLoC over Riverpod**
- **Reason**: Mature ecosystem, excellent testing support
- **Benefit**: Clear separation of business logic from UI

### 2. **Hive over SQLite**
- **Reason**: Type-safe, fast, minimal setup
- **Benefit**: Better performance for simple data structures

### 3. **Repository Pattern**
- **Reason**: Abstract data sources, enable offline-first
- **Benefit**: Easy to swap implementations, testable

### 4. **GetIt for DI**
- **Reason**: Simple service locator, no code generation
- **Benefit**: Easy setup, works well with testing

### 5. **Offline-First Architecture**
- **Reason**: Better user experience, works without internet
- **Benefit**: Immediate response, data persistence