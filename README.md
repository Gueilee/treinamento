# Quiz Finanças Ao Vivo

Quiz interativo (apresentador x participantes) usado no treinamento "Finanças para Não Financeiros" da Vendemmia. Publicado como Claude Artifact; o banco de dados roda no Supabase.

## Estrutura

- `quiz-financas.html` — código-fonte do quiz (HTML/CSS/JS), publicado como Claude Artifact.
- `supabase/migrations/0001_init.sql` — schema do banco: tabelas `participants`, `live_state`, `answers`, políticas de RLS e configuração de Realtime.

## Como funciona

- Cada participante entra pelo link, informa o nome uma vez (fica salvo no navegador) e responde pelo celular.
- O apresentador controla o avanço das perguntas e revela o gabarito; tudo sincroniza via Supabase Realtime.
- Cada resposta é gravada em `answers`, relacionada ao participante em `participants` — dá para consultar o resultado por pessoa depois do treinamento com:

```sql
select p.name, a.round, a.question_id, a.option_index, a.is_correct, a.created_at
from public.answers a
join public.participants p on p.id = a.participant_id
order by p.name, a.round, a.question_id;
```

## Configuração

1. Rode `supabase/migrations/0001_init.sql` no SQL Editor do projeto Supabase.
2. A chave usada no front-end (`SUPABASE_URL` / `SUPABASE_KEY` no topo do script) é a **publishable key** (pública por natureza — segura para expor no navegador). As tabelas têm RLS aberta para leitura/escrita anônima: é um trade-off deliberado para um quiz de treinamento sem dados sensíveis, sem exigir login.
3. Publique `quiz-financas.html` como Claude Artifact e libere o compartilhamento como "qualquer pessoa com o link".
