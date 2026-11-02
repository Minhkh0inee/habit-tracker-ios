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
        
        if lower.contains("swift") || lower.contains("ios") {
            return swiftConcepts
        } else if lower.contains("algorithm") || lower.contains("dsa") {
            return dsaConcepts
        } else if lower.contains("system design") || lower.contains("architecture") {
            return systemDesignConcepts
        } else if lower.contains("data engineering") || lower.contains("de") {
            return dataEngineeringConcepts
        } else if lower.contains("python") {
            return pythonConcepts
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
    
    // MARK: - System Design Curriculum
    public static let systemDesignConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Client-Server Architecture: HTTP/1.1 vs HTTP/2 vs gRPC",
            description: "Head-of-line blocking, multiplexing, binary protocols, protobuf serialization, and bi-directional streaming.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Load Balancing: L4 vs L7 & Consistent Hashing",
            description: "Transport vs Application layer proxying, virtual nodes on hash rings, and rebalancing node churn.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Caching Strategies: Cache-Aside, Write-Through & Write-Behind",
            description: "Redis and Memcached patterns, cache invalidation, thundering herd protection, and dogpiling mitigation.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Relational vs NoSQL: ACID vs BASE Tradeoffs",
            description: "B-Tree vs LSM-Tree storage engines, normalization vs denormalization, and eventual consistency.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Database Sharding, Partitioning & Replication",
            description: "Horizontal vs vertical partitioning, range-based vs hash sharding, read replicas, and split-brain resolution.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Message Brokers: Kafka vs RabbitMQ Architecture",
            description: "Log-centric partitioning, consumer groups, offset tracking, push vs pull semantics, and dead-letter queues.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Distributed Rate Limiting: Token Bucket & Sliding Window",
            description: "Leaky bucket, token bucket in Redis with Lua scripts, sliding window logs vs sliding window counters.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Distributed Transactions: 2-Phase Commit vs Saga Pattern",
            description: "Why 2PC fails in modern microservices, choreography vs orchestration sagas, and compensating actions.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Design TinyURL (URL Shortener) End-to-End",
            description: "Base62 encoding, unique ID generation (Snowflake), database schema, and high-read cache tiering.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Design a Scalable Notification System",
            description: "Priority queues for SMS/Email/Push, APNs/FCM workers, user notification settings, and deduplication.",
            estimatedMinutes: 40
        ),
        SeedConcept(
            title: "Design a Distributed Key-Value Store (DynamoDB Style)",
            description: "Gossip protocol, vector clocks for conflict resolution, quorum reads/writes (N, R, W), and hinted handoff.",
            estimatedMinutes: 45
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
    
    // MARK: - Python for DE Curriculum
    public static let pythonConcepts: [SeedConcept] = [
        SeedConcept(
            title: "Memory Management, GIL & Reference Counting in CPython",
            description: "How CPython allocates objects, cyclical garbage collector, and understanding the Global Interpreter Lock.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Generators, Iterators & 'yield' for Streaming Large Files",
            description: "Processing gigabyte-scale CSVs and log files with zero RAM bloat using streaming generator expressions.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Decorators & Context Managers (@contextmanager)",
            description: "Writing custom retry decorators with exponential backoff, resource pooling, and clean database session teardown.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Multiprocessing vs Threading vs Asyncio for Data Pipelines",
            description: "Choosing between ProcessPoolExecutor for CPU-bound transforms and Asyncio/ThreadPool for network I/O calls.",
            estimatedMinutes: 35
        ),
        SeedConcept(
            title: "Pandas Performance: Vectorization vs Itertuples vs Polars",
            description: "Why iterrows is slow, vectorized numpy operations, memory downcasting, and Polars lazy evaluation comparison.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Data Validation & Typing: Pydantic v2 & Type Hints",
            description: "Strict schema parsing, field validators, Rust-backed Pydantic v2 performance, and runtime model serialization.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "SQLAlchemy 2.0: Engine Connection Pooling & Sessions",
            description: "Bulk insert performance, managing connection lifecycles, statement execution, and transactional rollbacks.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "PyArrow & In-Memory Zero-Copy Columnar Interop",
            description: "Arrow tables, zero-copy conversion between Python and Parquet/Polars, and schema casting.",
            estimatedMinutes: 30
        ),
        SeedConcept(
            title: "Robust Data Pipeline CLI Tools with Typer / Click",
            description: "Building production command-line utilities with auto-generated help, environment flag overrides, and exit codes.",
            estimatedMinutes: 25
        ),
        SeedConcept(
            title: "Unit Testing Data Pipelines with Pytest & Docker Fixtures",
            description: "Mocking external APIs, spin up local Postgres/MinIO containers using pytest fixtures, and snapshot testing.",
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
