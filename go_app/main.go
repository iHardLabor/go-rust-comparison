package main

import (
	"sync"
)

const (
	numWorkers     = 100
	itemsPerWorker = 100000
	numShards      = 64 // Количество шардов для уменьшения контеншена
)

// Shard структура с собственной мапой и мьютексом
type Shard struct {
	mu   sync.Mutex
	data map[int][]int
}

func main() {
	shards := make([]*Shard, numShards)
	for i := 0; i < numShards; i++ {
		shards[i] = &Shard{data: make(map[int][]int)}
	}

	var wg sync.WaitGroup

	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go func(workerID int) {
			defer wg.Done()
			for j := 0; j < itemsPerWorker; j++ {
				// Выбираем шард на основе ключа j
				shardIdx := j % numShards
				shard := shards[shardIdx]

				shard.mu.Lock()
				shard.data[j] = append(shard.data[j], workerID)
				shard.mu.Unlock()
			}
		}(i)
	}

	wg.Wait()
}
