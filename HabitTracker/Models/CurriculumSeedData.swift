import Foundation

public struct SeedConcept {
    public let title: String
    public let description: String
    public let estimatedMinutes: Int
    
    public init(title: String, description: String, estimatedMinutes: Int) {
        self.title = title
        self.description = description
        self.estimatedMinutes = estimatedMinutes
    }
}

public enum CurriculumSeedData {
    public static func defaultConcepts(for habitTitle: String) -> [SeedConcept] {
        let lower = habitTitle.lowercased()
        
        // Match Python programming language specifically first
        if lower.contains("python") {
            return pythonConcepts
        } else if lower.contains("swift") || lower.contains("ios") {
            return swiftConcepts
        } else if lower.contains("algorithm") || lower.contains("dsa") {
            return dsaConcepts
        } else if lower.contains("system design") || lower.contains("architecture") {
            return systemDesignConcepts
        } else if lower.contains("data engineering") || lower.contains("data engineer") {
            return dataEngineeringConcepts
        } else {
            return genericEngineeringConcepts
        }
    }
    
    // MARK: - Swift & iOS Curriculum
    public static let swiftConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Value Types vs Reference Types & Copy-on-Write (CoW)",
            description: "Deep dive into Structs vs Classes, stack vs heap allocation, and how Swift optimizes CoW for Collections.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "ARC, Weak vs Unowned References & Retain Cycles",
            description: "Automatic Reference Counting mechanics, identifying memory leaks via Xcode Memory Graph and deinit checks.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Closures: Escaping, Non-Escaping & Capture Lists",
            description: "Understand [weak self] usage, @escaping closures in network callbacks, and @autoclosure optimization.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Protocols, Protocol Extensions & POP Paradigm",
            description: "Protocol-Oriented Programming, default implementations, polymorphism, and Static vs Dynamic dispatch.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Generics, Associated Types & Type Constraints",
            description: "Writing reusable generic algorithms, where clauses, and handling 'some' vs 'any' type erasure.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "SwiftUI State Management: @State, @Binding & @Observable",
            description: "Comparing old @ObservedObject / @Published with the modern iOS 17+ @Observable macro.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Swift Concurrency: async/await, Task & Cancellation",
            description: "Replacing completion handlers with structured concurrency, cooperative cancellation, and TaskGroup.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Actors, @MainActor & Data Race Prevention",
            description: "Thread isolation, reentrancy tradeoffs in Actors, and enforcing UI updates via @MainActor.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "SwiftData Architecture: ModelContainer & ModelContext",
            description: "Setting up schemas, relationships, cascade rules, background contexts, and lightweight schema migration.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "SwiftUI Layout Engine, GeometryReader & Preferences",
            description: "Understanding proposed sizes, alignment guides, safe area insets, and custom layout containers.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Instruments & Profiling: Time Profiler & Leaks",
            description: "Using Apple Instruments to track down CPU spikes, main thread hitches, and heap allocations.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Unit Testing & Mocking with XCTest & Swift Testing",
            description: "Writing deterministic unit tests, mocking URLSession protocols, and testing async code paths.",
            estimatedMinutes: 30
        )
    ]
    
    // MARK: - Data Structures & Algorithms
    public static let dsaConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Two Pointers & Fast/Slow Pointer Pattern",
            description: "Cycle detection (Floyd's algorithm), removing duplicates, and container with most water.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Sliding Window: Fixed vs Dynamic Length",
            description: "Longest substring without repeating characters, minimum window substring, and character count maps.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Binary Search: Lower Bound & Rotated Sorted Arrays",
            description: "Handling search spaces, boundary conditions (left < right vs left <= right), and search in rotated arrays.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Linked Lists: In-Place Reversal & Reorder List",
            description: "Iterative vs recursive node pointer swaps, dummy node technique, and merging K sorted lists.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Binary Trees: DFS Traversals & Lowest Common Ancestor (LCA)",
            description: "Preorder, Inorder, Postorder traversals, tree depth calculation, and subtree matching.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Binary Search Trees: Validation & Balanced BSTs",
            description: "Verifying BST properties with range bounds, AVL/Red-Black rotation intuition, and inorder succession.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Breadth-First Search (BFS): Level Order & Shortest Path",
            description: "Queue management, visited sets, rotting oranges, and word ladder word-transformation graphs.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Graphs: DFS Cycle Detection & Connected Components",
            description: "Color marking (white/gray/black) for directed graphs, number of islands, and clone graph.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Topological Sort: Kahn's Algorithm & Course Schedule",
            description: "In-degree array computation, cycle detection in DAGs, and task scheduling dependencies.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Heaps & Priority Queues: Top-K Frequent & Median Finder",
            description: "Min-heap vs Max-heap mechanics, two-heap median stream tracking, and k-closest points.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Dynamic Programming: 1D Memoization & Tabulation",
            description: "Climbing stairs, coin change, house robber, and identifying optimal substructure.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Dynamic Programming: 2D Longest Common Subsequence (LCS)",
            description: "Edit distance, grid pathing with obstacles, and 2D DP state transition matrices.",
            estimatedMinutes: 45
        ),
        SeedConcept(
            title: "Monotonic Stack: Next Greater Element & Daily Temperatures",
            description: "Maintaining increasing/decreasing stack invariants and calculating maximal histogram rectangles.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Trie (Prefix Tree): Construction & Word Search",
            description: "TrieNode array/dictionary implementation, autocomplete queries, and wildcard search.",
            estimatedMinutes: 30
        )
    ]
    
    // MARK: - System Design Curriculum (System-Design-Primer by Donne Martin)
    public static let systemDesignConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Performance vs Scalability & Latency vs Throughput",
            description: "Vertical vs horizontal scaling, service latency vs throughput trade-offs, and SLAs/SLOs in large systems.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Availability vs Consistency & The CAP Theorem",
            description: "CP vs AP systems, consistency patterns (weak, eventual, strong), and availability fail-over patterns.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "DNS & Content Delivery Networks (CDNs: Push vs Pull)",
            description: "Anycast routing, TTL tuning, CDN edge caching, and push vs pull caching architecture.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Load Balancers (L4 vs L7) & Reverse Proxies",
            description: "Transport vs Application layer proxying, consistent hashing with virtual nodes, and reverse proxy benefits.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Caching Architecture & Eviction Policies",
            description: "Cache-aside, write-through, write-behind, and eviction algorithms (LRU, LFU) across client, web, and DB tiers.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Relational Databases: Master-Slave, Federation & Sharding",
            description: "RDBMS scaling, master-slave replication, federation, horizontal sharding, denormalization, and B-Tree indexing.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "NoSQL: Key-Value, Document, Wide-Column & Graph Databases",
            description: "When to choose NoSQL, BASE vs ACID properties, and trade-offs between Redis, MongoDB, Cassandra, and Neo4j.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Asynchronous Processing: Message Queues & Pub-Sub",
            description: "Decoupling services, backpressure handling, task queues, and pub-sub architectures (RabbitMQ vs Kafka).",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Communication Protocols: TCP/UDP, HTTP, WebSockets & RPC",
            description: "Protocol trade-offs, HTTP/2 multiplexing, real-time bidirectional WebSockets, and high-performance gRPC/Protobuf.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "The 4-Step System Design Interview Framework & Estimations",
            description: "Scope clarification, back-of-the-envelope math (QPS, storage, bandwidth), high-level diagram, and bottleneck drill-down.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Case Study: Design a URL Shortener (TinyURL / Pastebin)",
            description: "Base62 hashing, unique ID generation (Snowflake), database schema, caching hot keys, and high read concurrency.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Case Study: Design Twitter Feed (Fanout-on-Write vs Read)",
            description: "User timeline vs home timeline generation, fanout service optimization, Redis list caching, and handling celebrity users.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Case Study: Design a Distributed Web Crawler",
            description: "URL frontier priority queues, DNS caching, duplicate content detection (SimHash), robots.txt, and worker scaling.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Object-Oriented Design (OOD): SOLID Principles & Clean Patterns",
            description: "Single Responsibility, Open-Closed, Liskov, Interface Segregation, Dependency Inversion, Factory, and Strategy patterns.",
            estimatedMinutes: 30
        )
    ]
    
    // MARK: - Data Engineering Curriculum
    public static let dataEngineeringConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Data Warehouses vs Data Lakes vs Lakehouses",
            description: "Evolution from traditional relational EDWs to modern open formats (Delta Lake, Apache Iceberg, Hudi).",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Dimensional Modeling: Star vs Snowflake Schemas",
            description: "Facts vs Dimensions, slowly changing dimensions (SCD Type 1, 2, 3), surrogate keys, and grain definition.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Columnar Storage Formats: Parquet vs ORC vs Avro",
            description: "Row vs columnar orientation, dictionary encoding, run-length encoding, Snappy compression, and predicate pushdown.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Apache Spark Core: RDD, DataFrames & Catalyst Optimizer",
            description: "Lazy evaluation, transformation vs action, logical vs physical plan optimization, and Whole-Stage Code Generation.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Spark Optimization: Partitioning, Salting & Skew Tuning",
            description: "Resolving shuffle spills, broadcast hash joins, custom partitioning, and handling skewed join keys with salting.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Streaming Architecture: Kafka Producer & Consumer Groups",
            description: "Partition assignment strategies, at-least-once vs exactly-once semantics (EOS), and consumer lag monitoring.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "CDC (Change Data Capture) with Debezium & Kafka Connect",
            description: "Streaming database write-ahead logs (WAL/Binlog) directly into downstream lakehouses without table polling.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Orchestration with Apache Airflow: DAGs, Sensors & Tasks",
            description: "Idempotent pipelines, backfilling historical partitions, dynamic task mapping, and custom Operators.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "dbt (Data Build Tool): Modular SQL Transformations & Tests",
            description: "Ref functions, ephemeral vs view vs table materializations, schema tests, and automated data documentation.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Data Quality & Contract Monitoring: Great Expectations",
            description: "Profiling datasets, schema validation in CI/CD, catching null-percentage anomalies before ingestion.",
            estimatedMinutes: 30
        )
    ]
    
    // MARK: - Python Programming Language Curriculum
    public static let pythonConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Python Data Model & Dunder Methods (__repr__, __getitem__, __len__)",
            description: "Understanding Python's object protocols, rich comparisons, sequence emulation, and building idiomatic custom container classes.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Memory Management & CPython Garbage Collection Internals",
            description: "Reference counting mechanics, circular reference resolution with generation 0/1/2 cyclical garbage collector, and weakref module.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Variable Binding, Mutability & Parameter Passing Gotchas",
            description: "Understanding 'pass-by-object-reference', mutable default arguments trap, shallow vs deep copy mechanics with copy.deepcopy.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Scopes, LEGB Rule & Closures (__closure__)",
            description: "Local, Enclosing, Global, and Built-in resolution rules, the 'nonlocal' and 'global' keywords, and inspecting closure cells.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Function & Class Decorators (@functools.wraps)",
            description: "Higher-order functions, writing parameterized decorators, class-based decorators, preserving signature/docstrings with wraps.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Iterables, Iterators Protocol & Custom Iterators",
            description: "Implementing __iter__ and __next__, handling StopIteration, and how Python for-loops work under the hood.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Generators, Generator Expressions & 'yield from'",
            description: "Writing stateful generators, memory-efficient streaming, coroutine delegation with 'yield from', and generator pipelines.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Context Managers Protocol (__enter__, __exit__ & contextlib)",
            description: "Resource lifecycle management, swallowing vs propagating exceptions in __exit__, and @contextmanager generators.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "OOP, Multiple Inheritance & C3 Linearization (MRO)",
            description: "Understanding Method Resolution Order, the C3 algorithm, cooperative multiple inheritance with super(), and Mixins.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Abstract Base Classes (abc.ABC) & Structural Typing (typing.Protocol)",
            description: "Enforcing interface contracts via @abstractmethod vs duck typing with @runtime_checkable Protocols.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Metaclasses, 'type' Constructor & __init_subclass__",
            description: "Class creation hooks, intercepting class definitions with custom metaclasses, and modern subclass validation via __init_subclass__.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "CPython Concurrency: GIL, Threading vs Multiprocessing",
            description: "Global Interpreter Lock bottlenecks, CPU-bound vs I/O-bound performance, thread safety, and inter-process queues.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Modern Asyncio: Coroutines, Tasks, Event Loop & async/await",
            description: "Non-blocking cooperative multitasking, task creation, handling cancellation, timeouts, and asyncio.gather vs TaskGroup.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Advanced Type Hints, Generics (TypeVar) & ParamSpec",
            description: "Writing type-safe Python libraries, generic classes, covariance vs contravariance, and validating with mypy.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Performance Optimization: __slots__, cProfile & Bytecode (dis)",
            description: "Eliminating instance __dict__ overhead with __slots__, analyzing bytecode instructions with dis, and profiling hot loops.",
            estimatedMinutes: 30
        )
    ]
    
    // Generic fallback for custom habits
    public static let genericEngineeringConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Foundations & Core Principles",
            description: "Setting up your environment, establishing fundamental building blocks, and baseline architecture.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Deep Dive: Core Mechanics & Patterns",
            description: "Exploring recurring design patterns, idiomatic practices, and common edge cases.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Practical Hands-on Project Implementation",
            description: "Applying the principles to build a working prototype or solve a realistic challenge.",
            estimatedMinutes: 45
        ),
        SeedConcept(
            title: "Performance Optimization & Refactoring",
            description: "Profiling execution bottlenecks, code cleanup, modularity, and test coverage.",
            estimatedMinutes: 35
        )
    ]
}
