# 04 — Data Storage

Storage is where data lives while it is being ingested, processed, and served.

## Storage evolution
- Local storage: simple but limited
- Object storage: great for raw files and scale
- Data lake: low-cost repository for raw and semi-structured data
- Data warehouse: query-optimized analytics store
- Data lakehouse: combines lake flexibility with warehouse structure
- Database: operational, transactional storage
- Distributed storage: scales horizontally across nodes

## Object storage
S3-like systems are ideal for low-cost, durable storage of large files.

### Characteristics
- bucket-based
- scalable and durable
- great for raw data

## Partitions
Breaking data into directories or segments by date, region, or other dimensions.

### Benefit
Faster queries and smaller scans

## File formats
- CSV: simple but inefficient for analytics
- JSON: flexible but verbose
- Parquet: columnar and efficient
- Avro: row-based, schema-aware
- ORC: columnar, common in Hadoop ecosystems

## Parquet
- compressed and columnar
- efficient for analytics
- supports predicate pushdown and pruning

## Compression
Reduces storage and I/O cost but adds CPU usage.

## Columnar vs row-oriented
- Row-oriented: good for transactional workloads
- Column-oriented: good for analytical queries

## Why choose one storage type over another?
- raw low-cost storage -> object storage / lake
- high-performance analytics -> warehouse or lakehouse
- transactional app data -> database

## Must Know
- Object storage and lakehouse fundamentals
- Partitioning and file formats
- Parquet vs CSV
- Columnar vs row-oriented

## Good to Know
- Avro and ORC
- Local and distributed storage limits

## Advanced
- Storage tiering
- Multi-zone durability

## Interview Questions
1. Why is object storage useful for a data lake?
2. When would you choose a warehouse instead of a lake?
3. Why is Parquet preferred for analytics?
4. What is the benefit of partitioning by date?
5. What is the trade-off of compression?
