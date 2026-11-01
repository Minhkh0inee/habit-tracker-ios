import Foundation

public struct EngineeringConcept: Identifiable, Hashable {
    public let id = UUID()
    public let category: String
    public let title: String
    public let summary: String
    
    public init(category: String, title: String, summary: String) {
        self.category = category
        self.title = title
        self.summary = summary
    }
}

public enum EngineeringConceptBank {
    public static let curatedConcepts: [EngineeringConcept] = [
        // MARK: - DSA
        EngineeringConcept(
            category: "Computer Science",
            title: "Two Pointers Technique",
            summary: "Using left and right indices on sorted arrays to reduce O(N^2) search to O(N) linear time with O(1) space."
        ),
        EngineeringConcept(
            category: "Computer Science",
            title: "Sliding Window Pattern",
            summary: "Expanding and shrinking window boundaries to solve contiguous subarray/substring maximum and minimum constraints."
        ),
        EngineeringConcept(
            category: "Computer Science",
            title: "Monotonic Stack",
            summary: "Maintaining strictly increasing or decreasing stack order to solve next greater/smaller element in O(N)."
        ),
        EngineeringConcept(
            category: "Computer Science",
            title: "Binary Search Invariants",
            summary: "Maintaining search space boundaries (low <= high vs low < high) and avoiding infinite loops in division."
        ),
        EngineeringConcept(
            category: "Computer Science",
            title: "Dynamic Programming: Memoization vs Tabulation",
            summary: "Top-down recursion with caching vs bottom-up iterative table construction to avoid overlapping subproblems."
        ),
        EngineeringConcept(
            category: "Computer Science",
            title: "LRU Cache Design",
            summary: "Combining Hash Map (O(1) lookup) with Doubly Linked List (O(1) removal/insertion at head and tail)."
        ),
        
        // MARK: - System Design
        EngineeringConcept(
            category: "Architecture",
            title: "Consistent Hashing & Virtual Nodes",
            summary: "Distributing keys across a ring topology to minimize rebalancing overhead when cache/database nodes scale up or down."
        ),
        EngineeringConcept(
            category: "Architecture",
            title: "CAP Theorem Tradeoffs",
            summary: "In a network partition (P), choosing between Consistency (linearizable reads) and Availability (always accepting writes)."
        ),
        EngineeringConcept(
            category: "Architecture",
            title: "Database Sharding & Partition Keys",
            summary: "Horizontal partitioning strategies, handling hot spots, scatter-gather queries, and cross-shard transactions."
        ),
        EngineeringConcept(
            category: "Architecture",
            title: "Kafka Partitioning & Consumer Rebalancing",
            summary: "Ordered log append per partition, consumer group offset commits, and partition assignment strategies."
        ),
        EngineeringConcept(
            category: "Architecture",
            title: "Rate Limiting: Token Bucket vs Leaky Bucket",
            summary: "Token bucket allowing bursts up to bucket capacity vs leaky bucket enforcing a strict steady outflow rate."
        ),
        
        // MARK: - Swift & iOS
        EngineeringConcept(
            category: "Mobile",
            title: "ARC, Weak vs Unowned References",
            summary: "Breaking retain cycles in closures and delegates; weak zeroing weak pointers vs unowned non-zeroing references."
        ),
        EngineeringConcept(
            category: "Mobile",
            title: "Swift 6 Concurrency & Actors",
            summary: "Data-race safety with Sendable conformance, actor isolation, and cooperative thread pool execution."
        ),
        EngineeringConcept(
            category: "Mobile",
            title: "Value vs Reference Types & COW",
            summary: "Structs and Enums copied on write (COW) with value semantics vs Classes stored on heap with reference semantics."
        ),
        EngineeringConcept(
            category: "Mobile",
            title: "SwiftUI State & Observation Lifecycle",
            summary: "Macro-based @Observable tracking exact property mutations for fine-grained subview invalidation."
        ),
        
        // MARK: - Data Engineering
        EngineeringConcept(
            category: "Data",
            title: "Star vs Snowflake Schema",
            summary: "Denormalized dimensions for fast OLAP aggregation (Star) vs normalized hierarchies saving storage (Snowflake)."
        ),
        EngineeringConcept(
            category: "Data",
            title: "Spark Catalyst Optimizer & Shuffle Tuning",
            summary: "Logical to physical query plan optimization, predicate pushdown, and tuning spark.sql.shuffle.partitions."
        ),
        EngineeringConcept(
            category: "Data",
            title: "Columnar Storage: Parquet vs Row Storage",
            summary: "Column projection, dictionary encoding, run-length encoding, and min/max statistics for analytical scans."
        ),
        EngineeringConcept(
            category: "Data",
            title: "Idempotency in Data Pipelines",
            summary: "Designing ETL/ELT pipelines with deterministic partitions and upsert/merge logic so replays cause zero duplicates."
        ),
        
        // MARK: - Python for DE
        EngineeringConcept(
            category: "Languages & Tools",
            title: "Generators & Memory Footprint",
            summary: "Yielding values lazily using iterators to process terabyte data streams without loading everything into RAM."
        ),
        EngineeringConcept(
            category: "Languages & Tools",
            title: "Python GIL & Concurrency",
            summary: "Global Interpreter Lock preventing multi-core Python bytecode execution; using multiprocessing for CPU-bound tasks."
        ),
        EngineeringConcept(
            category: "Languages & Tools",
            title: "Vectorized Operations in Pandas/Polars",
            summary: "Replacing Python for-loops with SIMD C/Rust vectorized columnar primitives for 100x speedup."
        )
    ]
    
    public static func concepts(for category: String) -> [EngineeringConcept] {
        curatedConcepts.filter {
            $0.category.localizedCaseInsensitiveContains(category) ||
            category.localizedCaseInsensitiveContains($0.category)
        }
    }
}
