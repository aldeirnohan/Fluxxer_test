<?php

namespace App\Jobs;

use App\Models\Task;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessTask implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $taskId;

    /**
     * Create a new job instance.
     */
    public function __construct(int $taskId)
    {
        $this->taskId = $taskId;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        try {
            Log::info("Iniciando processamento da task ID: {$this->taskId}");

            // Simular processamento com sleep(5)
            sleep(5);

            // Buscar a task e atualizar status para 'done'
            $task = Task::find($this->taskId);
            
            if ($task) {
                $task->update(['status' => 'done']);
                Log::info("Task ID: {$this->taskId} processada com sucesso. Status atualizado para 'done'");
            } else {
                Log::error("Task ID: {$this->taskId} não encontrada");
            }

        } catch (\Exception $e) {
            Log::error("Erro ao processar task ID: {$this->taskId}. Erro: " . $e->getMessage());
            
            // Atualizar status para 'processing' em caso de erro
            $task = Task::find($this->taskId);
            if ($task) {
                $task->update(['status' => 'processing']);
            }
            
            throw $e;
        }
    }
}