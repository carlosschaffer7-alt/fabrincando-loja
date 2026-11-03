
-- FABRINCANDO IDEIAS - SUPABASE SCHEMA
-- Criar no SQL Editor do Supabase com o usuário carlos@fabrincandoideias.com.br

-- 1. Produtos fábrica
create table if not exists produtos (
  id uuid primary key default gen_random_uuid(),
  ref text unique not null,
  nome text not null,
  categoria text not null,
  preco_de numeric(10,2) not null,
  preco_por numeric(10,2) not null,
  preco_pix numeric(10,2) generated always as (preco_por * 0.9) stored,
  estoque int default 0,
  desconto_percent numeric(5,2) generated always as (case when preco_de > 0 then ((1 - preco_por/preco_de)*100) else 0 end) stored,
  ativo boolean default true,
  created_at timestamp with time zone default now()
);

-- 2. Temas / Fotos (mesmo produto, vários temas, mesmo valor)
create table if not exists produto_temas (
  id uuid primary key default gen_random_uuid(),
  produto_ref text references produtos(ref) on delete cascade,
  tema_nome text not null,
  foto_url text,
  ordem int default 0,
  created_at timestamp default now()
);

-- 3. Usuários Admin
create table if not exists usuarios_admin (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  nome text,
  role text check (role in ('admin','editor','vendedor')) default 'editor',
  ativo boolean default true,
  created_at timestamp default now()
);

-- 4. Pedidos B2C
create table if not exists pedidos_b2c (
  id uuid primary key default gen_random_uuid(),
  cliente_nome text,
  cliente_email text,
  cliente_whatsapp text,
  cliente_cpf text,
  total numeric(10,2),
  forma_pagamento text check (forma_pagamento in ('pix','cartao_3x')),
  status text default 'novo',
  itens jsonb,
  created_at timestamp default now()
);

-- 5. Inserir seus 6 produtos iniciais
insert into produtos (ref, nome, categoria, preco_de, preco_por, estoque) values
('6501', 'BOMBEIROS HEROIS', 'Barracas Casinha', 189.90, 110.88, 100),
('7102', 'AMIGAS SEREIAS', 'Barracas Casinha', 189.90, 110.88, 71),
('9609', 'DINOSSAUROS', 'Pop Up', 153.06, 89.51, 200),
('5250', 'GALINHA AZULZINHA com 40 Bol', 'Kits 3 em 1', 422.66, 247.17, 281),
('0688', 'CERCADO BALAO ROSA - PROTECAO', 'Cercados', 287.28, 168.00, 27),
('5441', 'PIZZARIA', 'Barraca Toldo', 201.46, 117.81, 96)
on conflict (ref) do nothing;

-- 6. Storage buckets (criar via Dashboard > Storage)
-- Bucket: produto-fotos - public true

-- 7. Policies (liberar leitura pública dos produtos)
alter table produtos enable row level security;
create policy "Leitura publica produtos" on produtos for select using (true);
create policy "Admin pode tudo produtos" on produtos for all using (true);

alter table produto_temas enable row level security;
create policy "Leitura publica temas" on produto_temas for select using (true);
create policy "Admin pode tudo temas" on produto_temas for all using (true);

alter table pedidos_b2c enable row level security;
create policy "Inserir pedidos publico" on pedidos_b2c for insert with check (true);
create policy "Admin ver pedidos" on pedidos_b2c for select using (true);
