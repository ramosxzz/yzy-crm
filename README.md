# yzy CRM

<p align="center">
  <img src="./assets/icon.png" width="120" height="120" alt="yzy CRM Logo">
</p>

<p align="center">
  <b>CRM minimalista e personalizável para gestão de projetos e reuniões.</b>
</p>

<p align="center">
  <img alt="GitHub Pages" src="https://img.shields.io/badge/deployed%20on-GitHub%20Pages-blue?logo=github">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
  <img alt="Supabase" src="https://img.shields.io/badge/database-Supabase-3ECF8E?logo=supabase">
</p>

---

## Visão Geral

O **yzy CRM** é um sistema de gestão de relacionamento com clientes (CRM) minimalista, inspirado no design da Apple, desenvolvido para uso pessoal e profissional. Com uma interface limpa, clara e elegante, o CRM permite gerenciar projetos, reuniões e notas de forma eficiente.

### Principais Características

- **Design Apple-inspired** - Interface limpa, minimalista e elegante com tipografia e cores refinadas.
- **Gestão de Projetos** - Crie, edite e acompanhe projetos com status, prioridade, empresa e prazo.
- **Gestão de Reuniões** - Agende reuniões com data, hora, duração e empresa. Marque como concluídas.
- **Upload de Imagens** - Adicione imagens de capa aos projetos por upload de arquivo.
- **Perfil Personalizado** - Configure seu nome, foto, bio e cor do tema.
- **Filtros por Empresa** - Separe projetos e reuniões por empresa (SOLAIRE, AVANTE, Pessoal).
- **Tema Claro/Escuro** - Alterne entre tema claro e escuro conforme sua preferência.
- **PWA** - Progressive Web App, pode ser instalado no celular como um app nativo.
- **Responsivo** - Funciona perfeitamente em desktop, tablet e mobile.

---

## Screenshots

### Dashboard - Projetos
![Dashboard Projetos](https://via.placeholder.com/800x400?text=Dashboard+Projetos)

### Lista de Reuniões
![Reuniões](https://via.placeholder.com/800x400?text=Lista+de+Reuniões)

### Detalhes do Projeto
![Detalhes Projeto](https://via.placeholder.com/800x400?text=Detalhes+do+Projeto)

### Modal de Perfil
![Perfil](https://via.placeholder.com/800x400?text=Perfil+Personalizado)

---

## Tech Stack

| Tecnologia | Uso |
|------------|-----|
| **HTML5** | Estrutura semântica e markup |
| **CSS3** | Estilização com variáveis CSS, flexbox, grid |
| **Vanilla JavaScript** | Lógica da aplicação sem frameworks |
| **Supabase** | Banco de dados PostgreSQL em tempo real |
| **GitHub Pages** | Hospedagem gratuita e rápida |
| **PWA** | Manifest e service worker para instalação no dispositivo |

---

## Estrutura do Projeto

```
yzy-crm/
├── index.html              # Página principal (SPA)
├── manifest.json           # Manifesto do PWA
├── profiles-schema.sql     # Schema da tabela de perfis
├── supabase-schema.sql     # Schema completo do banco de dados
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Action para deploy automático
├── assets/
│   ├── icon.png            # Ícone do PWA e favicon
│   └── favicon.svg         # Favicon SVG (fallback)
└── README.md               # Este arquivo
```

---

## Como Usar

### 1. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/yzy-crm.git
cd yzy-crm
```

### 2. Configurar o Supabase

1. Crie uma conta gratuita em [supabase.com](https://supabase.com).
2. Crie um novo projeto.
3. No SQL Editor, execute o conteúdo do arquivo `supabase-schema.sql`.
4. Execute também o `profiles-schema.sql` para criar a tabela de perfis.
5. Copie a **URL** e a **anon key** do seu projeto.
6. No arquivo `index.html`, substitua as constantes `SUPABASE_URL` e `SUPABASE_KEY` pelas suas credenciais.

```javascript
const SUPABASE_URL = 'https://seu-projeto.supabase.co';
const SUPABASE_KEY = 'sua-anon-key';
```

### 3. Deploy no GitHub Pages

1. Crie um novo repositório no GitHub.
2. Habilite o GitHub Pages em **Settings > Pages > Source: GitHub Actions**.
3. Envie o código:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/seu-usuario/yzy-crm.git
git push -u origin main
```

4. O GitHub Action fará o deploy automaticamente.
5. Acesse seu CRM em `https://seu-usuario.github.io/yzy-crm/`.

---

## Funcionalidades

### Projetos

- **Criar projeto** com título, descrição, status, prioridade, empresa, pasta, prazo, URL e imagem.
- **Status**: A Fazer, Em Andamento, Em Revisão, Finalizado, Bloqueado.
- **Prioridade**: Baixa, Média, Alta, Urgente.
- **Empresas**: SOLAIRE, AVANTE, Pessoal.
- **Filtro rápido** pelos cards de estatísticas (Total, Andamento, Finalizados, Bloqueados).
- **Adicionar notas** dentro de cada projeto.

### Reuniões

- **Criar reunião** com título, descrição, data, hora, duração e empresa.
- **Seções separadas**: Próximas Reuniões, Concluídas, Passadas/Canceladas.
- **Marcar como concluída** com um clique.

### Perfil

- **Foto de perfil** com upload de imagem.
- **Nome e bio** personalizáveis.
- **Cor do tema** com 8 presets e color picker customizado.
- Nome do perfil aparece no header ao lado do título da página.

---

## Banco de Dados

### Tabelas

| Tabela | Descrição |
|--------|-----------|
| `projects` | Projetos com título, descrição, status, prioridade, empresa, prazo, URL e imagem |
| `meetings` | Reuniões com título, descrição, data, hora, duração, empresa e status |
| `folders` | Pastas para organização de projetos (com suporte a subpastas) |
| `notes` | Notas associadas a projetos |
| `profiles` | Perfil do usuário com nome, bio, avatar e cor do tema |

---

## Licença

Este projeto está licenciado sob a licença **MIT**.

```
MIT License

Copyright (c) 2026 yzy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<p align="center">
  Feito com carinho para uso pessoal e profissional.
</p>
