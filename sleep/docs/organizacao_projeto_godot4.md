# Organizacao de Arquivos - Godot 4

## Antes de comecar

Este passo a passo deve ser feito pelo `FileSystem` do editor do Godot, nao pelo explorador do Windows. Assim o Godot atualiza dependencias, `.import` e referencias internas com seguranca.

Observacao importante: no estado atual do projeto, varias pastas de destino ja existem, mas muitos arquivos ainda estao nas pastas antigas. Entao a migracao correta e mover os arquivos antigos para dentro da estrutura nova, e so depois validar.

## Ordem correta

1. Abra o projeto `sleep` no Godot.
2. No painel `FileSystem`, confirme que a raiz do projeto e `res://`.
3. Crie qualquer pasta de destino que ainda nao exista.
4. Mova primeiro as cenas de teste e objetos compartilhados.
5. Depois mova todo o conteudo do jogador Jason Grimm.
6. Em seguida mova o inimigo aranha de `minios` para `minions`.
7. Por ultimo, mova o arquivo legado duplicado.
8. Espere o Godot terminar a reimportacao.
9. Rode `res://fases/testes/base_de_teste.tscn`.
10. Rode tambem a cena principal do jogador para validar preload, scripts e hitboxes.

## Estrutura de destino

```text
res://
├── addons/
├── audio/
│   ├── musica/
│   ├── sfx/
│   └── vozes/
├── cinematics/
├── dados/
│   ├── configuracoes/
│   └── save/
├── docs/
├── efeitos_visuais/
│   ├── impactos/
│   └── particulas/
├── fases/
│   ├── blocos_de_fase/
│   ├── hubs/
│   └── testes/
├── legado/
│   └── cenas_antigas/
├── objetos_interativos/
│   ├── empurraveis/
│   └── quebraveis/
├── personagens/
│   ├── inimigos/
│   │   └── minions/
│   │       └── spider/
│   │           ├── animacoes/
│   │           │   └── recursos/
│   │           ├── cenas/
│   │           ├── modelos/
│   │           └── scripts/
│   ├── jogador/
│   │   └── jason_grimm/
│   │       ├── animacoes/
│   │       │   ├── fontes/
│   │       │   └── recursos/
│   │       ├── cenas/
│   │       ├── combate/
│   │       │   └── hitboxes/
│   │       ├── efeitos/
│   │       │   └── dash/
│   │       ├── habilidades/
│   │       │   ├── esfera_sombria/
│   │       │   ├── lamina_sombra/
│   │       │   └── sombra_viva/
│   │       ├── modelos/
│   │       ├── scripts/
│   │       └── ui/
│   │           └── hud/
│   └── npcs/
├── sistemas/
│   ├── camera/
│   ├── combate/
│   ├── interacao/
│   ├── inventario/
│   └── save/
└── ui/
	├── hud/
	├── menus/
	└── widgets/
```

## Passo a passo no Godot

### 1. Cenas de fase e prototipo

Mova:

- `res://base_de_teste.tscn` -> `res://fases/testes/base_de_teste.tscn`

### 2. Objetos interativos

Mova:

- `res://caixa_pesada.tscn` -> `res://objetos_interativos/empurraveis/caixa_pesada.tscn`
- `res://boneco_treino.tscn` -> `res://objetos_interativos/quebraveis/boneco_treino.tscn`
- `res://personagens/jason grimm/scripts/boneco_treino.gd` -> `res://objetos_interativos/quebraveis/boneco_treino.gd`

### 3. Jogador Jason Grimm

Primeiro mova a cena, script principal e modelo:

- `res://personagens/jason grimm/jason_grimm.tscn` -> `res://personagens/jogador/jason_grimm/cenas/jason_grimm.tscn`
- `res://personagens/jason grimm/scripts/jason_grimm.gd` -> `res://personagens/jogador/jason_grimm/scripts/jason_grimm.gd`
- `res://personagens/jason grimm/jason.fbx` -> `res://personagens/jogador/jason_grimm/modelos/jason.fbx`

Depois mova animacoes e recursos:

- `res://personagens/jason grimm/animacoes/` -> `res://personagens/jogador/jason_grimm/animacoes/fontes/`
- `res://personagens/jason grimm/animacoes.res/` -> `res://personagens/jogador/jason_grimm/animacoes/recursos/`

### 4. UI do jogador

Mova:

- `res://personagens/jason grimm/hud.tscn` -> `res://personagens/jogador/jason_grimm/ui/hud/hud.tscn`
- `res://personagens/jason grimm/hud.gd` -> `res://personagens/jogador/jason_grimm/ui/hud/hud.gd`

### 5. Habilidades e efeitos do jogador

Mova:

- `res://personagens/jason grimm/esfera_sombria.tscn` -> `res://personagens/jogador/jason_grimm/habilidades/esfera_sombria/esfera_sombria.tscn`
- `res://personagens/jason grimm/lamina_sombra.tscn` -> `res://personagens/jogador/jason_grimm/habilidades/lamina_sombra/lamina_sombra.tscn`
- `res://personagens/jason grimm/scripts/lamina_sombra.gd` -> `res://personagens/jogador/jason_grimm/habilidades/lamina_sombra/lamina_sombra.gd`
- `res://personagens/jason grimm/sombra_viva.tscn` -> `res://personagens/jogador/jason_grimm/habilidades/sombra_viva/sombra_viva.tscn`
- `res://personagens/jason grimm/scripts/sombra_viva.gd` -> `res://personagens/jogador/jason_grimm/habilidades/sombra_viva/sombra_viva.gd`
- `res://personagens/jason grimm/Efeitos Visuais/dash/dash_ghost.tscn` -> `res://personagens/jogador/jason_grimm/efeitos/dash/dash_ghost.tscn`
- `res://personagens/jason grimm/scripts/dash_ghost.gd` -> `res://personagens/jogador/jason_grimm/efeitos/dash/dash_ghost.gd`

### 6. Hitboxes do jogador

Mova:

- `res://personagens/jason grimm/scripts/hitbox_mao_direita.gd` -> `res://personagens/jogador/jason_grimm/combate/hitboxes/hitbox_mao_direita.gd`
- `res://personagens/jason grimm/scripts/hitbox_mao_esquerda.gd` -> `res://personagens/jogador/jason_grimm/combate/hitboxes/hitbox_mao_esquerda.gd`
- `res://personagens/jason grimm/scripts/hitbox_perna_direita.gd` -> `res://personagens/jogador/jason_grimm/combate/hitboxes/hitbox_perna_direita.gd`
- `res://personagens/jason grimm/scripts/hitbox_perna_esquerda.gd` -> `res://personagens/jogador/jason_grimm/combate/hitboxes/hitbox_perna_esquerda.gd`

### 7. Inimigo aranha

Mova:

- `res://personagens/inimigos/minios/spider/inimigo_aranha.tscn` -> `res://personagens/inimigos/minions/spider/cenas/inimigo_aranha.tscn`
- `res://personagens/inimigos/minios/spider/inimigo_aranha.gd` -> `res://personagens/inimigos/minions/spider/scripts/inimigo_aranha.gd`
- `res://personagens/inimigos/minios/spider/dano_do_corpo.gd` -> `res://personagens/inimigos/minions/spider/scripts/dano_do_corpo.gd`
- `res://personagens/inimigos/minios/spider/hitbox_direita_1.gd` -> `res://personagens/inimigos/minions/spider/scripts/hitbox_direita_1.gd`
- `res://personagens/inimigos/minios/spider/hitbox_esquerda_1.gd` -> `res://personagens/inimigos/minions/spider/scripts/hitbox_esquerda_1.gd`
- `res://personagens/inimigos/minios/spider/Spider.fbx` -> `res://personagens/inimigos/minions/spider/modelos/Spider.fbx`
- `res://personagens/inimigos/minios/spider/animacoes.res/` -> `res://personagens/inimigos/minions/spider/animacoes/recursos/`

### 8. Arquivo legado

Mova:

- `res://jason_grimm.tscn` -> `res://legado/cenas_antigas/jason_grimm.tscn`

## Preloads que ja estao esperando a estrutura nova

No script do jogador, os caminhos preparados sao estes:

- `res://personagens/jogador/jason_grimm/efeitos/dash/dash_ghost.tscn`
- `res://personagens/jogador/jason_grimm/habilidades/esfera_sombria/esfera_sombria.tscn`
- `res://personagens/jogador/jason_grimm/habilidades/sombra_viva/sombra_viva.tscn`

Por isso, faca a migracao no Godot antes de testar o personagem.

## Validacao final

Depois de mover tudo:

1. Espere o Godot reimportar os arquivos.
2. Abra `res://fases/testes/base_de_teste.tscn`.
3. Rode a cena e veja se nao ha erro de recurso faltando.
4. Abra a cena principal do jogador em `res://personagens/jogador/jason_grimm/cenas/jason_grimm.tscn`.
5. Rode a cena do jogador.
6. Teste movimento, dash, esfera sombria, sombra viva e ataques com hitbox.
7. Se algum recurso quebrar, verifique se ele ainda ficou na pasta antiga.

## Observacoes de arquitetura

- `minios` deve ser tratado como nome antigo; a estrutura viva passa a ser `minions`.
- `legado/` serve para absorver duplicatas e cenas antigas sem poluir a estrutura principal.
- Em Godot, manter cena, script e recursos proximos por feature costuma escalar melhor do que concentrar tudo em uma pasta unica de scripts.
