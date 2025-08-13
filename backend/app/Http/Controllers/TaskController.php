<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class TaskController extends Controller
{
    /**
     * Display a listing of the tasks.
     */
    public function index(): JsonResponse
    {
        try {
            // Buscar todas as tasks ordenadas por data de criação (mais recentes primeiro)
            $tasks = Task::orderBy('created_at', 'desc')->get();

            return response()->json([
                'success' => true,
                'message' => 'Tasks listadas com sucesso',
                'data' => $tasks,
                'count' => $tasks->count()
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao listar tasks',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created task in storage.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            // Validar dados da requisição
            $validated = $request->validate([
                'title' => 'required|string|max:255',
            ]);

            // Criar a task com status 'pending' por padrão
            $task = Task::create([
                'title' => $validated['title'],
                'status' => 'pending',
            ]);

            // Retornar resposta de sucesso
            return response()->json([
                'success' => true,
                'message' => 'Task criada com sucesso',
                'data' => $task
            ], 201);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}