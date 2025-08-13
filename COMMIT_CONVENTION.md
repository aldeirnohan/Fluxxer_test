# Convenções de Commit

Este documento define as convenções para mensagens de commit neste projeto.

## Formato da Mensagem

```
<tipo>(<escopo>): <descrição>

[corpo opcional]

[rodapé opcional]
```

## Tipos

- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **docs**: Documentação
- **style**: Formatação, ponto e vírgula faltando, etc; sem mudança de código
- **refactor**: Refatoração de código de produção
- **test**: Adicionando testes, refatorando testes; sem mudança de código de produção
- **chore**: Atualização de tarefas de build, configurações, etc; sem mudança de código de produção

## Escopo

O escopo deve ser o nome do componente afetado (opcional).

## Descrição

A descrição deve ser clara e concisa, usando imperativo.

## Exemplos

```
feat(auth): adiciona autenticação JWT
fix(api): corrige validação de email
docs(readme): atualiza instruções de instalação
style: formata código com prettier
refactor(database): otimiza consultas SQL
test(users): adiciona testes para CRUD de usuários
chore(docker): atualiza versão do PHP para 8.2
```

## Regras

1. Use imperativo na descrição ("adiciona" não "adicionado")
2. Não termine a descrição com ponto
3. Use escopo quando apropriado
4. Seja específico sobre o que foi alterado
5. Para commits que fecham issues, use "Closes #123" no rodapé

## Padrão para Pull Requests

- **Título**: Use o mesmo formato das mensagens de commit
- **Descrição**: Explique o que foi feito e por quê
- **Testes**: Descreva como testar as mudanças
- **Breaking Changes**: Documente mudanças que quebram compatibilidade 