
import 'package:flutter/material.dart';

void main() {
  runApp(const Controle_VendasApp());
}

class Cliente {
  String nome, cpf, telefone, turma, turno;

  Cliente({
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.turma,
    required this.turno,
  });
}

class Produto {
  String nome, descricao, unidade;
  double valor;

  Produto({
    required this.nome,
    required this.descricao,
    required this.unidade,
    required this.valor,
  });
}

class Venda {
  Cliente cliente;
  Produto produto;
  int quantidade;
  DateTime data;

  Venda({
    required this.cliente,
    required this.produto,
    required this.quantidade,
    required this.data,
  });

  double get total => produto.valor * quantidade;
}

class Controle_VendasApp extends StatelessWidget {
  const Controle_VendasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Vendas - Cantina CEET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int telaAtual = 0;

  final List<Cliente> clientes = [];
  final List<Produto> produtos = [];
  final List<Venda> vendas = [];

  final List<String> titulos = [
    'Clientes',
    'Produtos',
    'Vendas',
    'Consulta',
  ];

  String dinheiro(double valor) => 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  Future<String?> texto({
    required String titulo,
    required String rotulo,
    String inicial = '',
  }) async {
    final controller = TextEditingController(text: inicial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: rotulo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> cadastrarCliente([Cliente? existente]) async {
    final nome = await texto(
      titulo: existente == null ? 'Novo cliente' : 'Editar cliente',
      rotulo: 'Nome',
      inicial: existente?.nome ?? '',
    );
    if (nome == null || nome.isEmpty || !mounted) return;

    final cpf = await texto(
      titulo: 'Dados do cliente',
      rotulo: 'CPF',
      inicial: existente?.cpf ?? '',
    );
    if (cpf == null || cpf.isEmpty || !mounted) return;

    final telefone = await texto(
      titulo: 'Dados do cliente',
      rotulo: 'Telefone',
      inicial: existente?.telefone ?? '',
    );
    if (telefone == null || telefone.isEmpty || !mounted) return;

    final turma = await texto(
      titulo: 'Dados do cliente',
      rotulo: 'Turma',
      inicial: existente?.turma ?? '',
    );
    if (turma == null || turma.isEmpty || !mounted) return;

    final turno = await texto(
      titulo: 'Dados do cliente',
      rotulo: 'Turno',
      inicial: existente?.turno ?? '',
    );
    if (turno == null || turno.isEmpty || !mounted) return;

    setState(() {
      if (existente == null) {
        clientes.add(Cliente(
          nome: nome,
          cpf: cpf,
          telefone: telefone,
          turma: turma,
          turno: turno,
        ));
      } else {
        existente
          ..nome = nome
          ..cpf = cpf
          ..telefone = telefone
          ..turma = turma
          ..turno = turno;
      }
    });
  }

  Future<void> cadastrarProduto([Produto? existente]) async {
    final nome = await texto(
      titulo: existente == null ? 'Novo produto' : 'Editar produto',
      rotulo: 'Nome',
      inicial: existente?.nome ?? '',
    );
    if (nome == null || nome.isEmpty || !mounted) return;

    final descricao = await texto(
      titulo: 'Dados do produto',
      rotulo: 'Descrição',
      inicial: existente?.descricao ?? '',
    );
    if (descricao == null || descricao.isEmpty || !mounted) return;

    final unidade = await texto(
      titulo: 'Dados do produto',
      rotulo: 'Unidade (ex.: unidade, pacote)',
      inicial: existente?.unidade ?? '',
    );
    if (unidade == null || unidade.isEmpty || !mounted) return;

    final valorTexto = await texto(
      titulo: 'Dados do produto',
      rotulo: 'Valor (ex.: 5,50)',
      inicial: existente?.valor.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    if (valorTexto == null || !mounted) return;

    final valor = double.tryParse(valorTexto.replaceAll(',', '.'));
    if (valor == null || valor < 0) {
      mensagem('Informe um valor numérico válido.');
      return;
    }

    setState(() {
      if (existente == null) {
        produtos.add(Produto(
          nome: nome,
          descricao: descricao,
          unidade: unidade,
          valor: valor,
        ));
      } else {
        existente
          ..nome = nome
          ..descricao = descricao
          ..unidade = unidade
          ..valor = valor;
      }
    });
  }

  Future<void> cadastrarVenda([Venda? existente]) async {
    if (clientes.isEmpty || produtos.isEmpty) {
      mensagem('Cadastre pelo menos um cliente e um produto antes de registrar uma venda.');
      return;
    }

    Cliente? clienteSelecionado = existente?.cliente ?? clientes.first;
    Produto? produtoSelecionado = existente?.produto ?? produtos.first;
    final quantidadeController = TextEditingController(
      text: (existente?.quantidade ?? 1).toString(),
    );
    DateTime dataSelecionada = existente?.data ?? DateTime.now();

    final resultado = await showDialog<Venda>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, atualizarDialogo) => AlertDialog(
          title: Text(existente == null ? 'Nova venda' : 'Editar venda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Cliente>(
                  value: clienteSelecionado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: clientes.map((cliente) {
                    return DropdownMenuItem(
                      value: cliente,
                      child: Text(cliente.nome),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    atualizarDialogo(() => clienteSelecionado = valor);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Produto>(
                  value: produtoSelecionado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Produto'),
                  items: produtos.map((produto) {
                    return DropdownMenuItem(
                      value: produto,
                      child: Text('${produto.nome} - ${dinheiro(produto.valor)}'),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    atualizarDialogo(() => produtoSelecionado = valor);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                ),
                const SizedBox(height: 12),
                Text('Data: ${dataSelecionada.day.toString().padLeft(2, '0')}/'
                    '${dataSelecionada.month.toString().padLeft(2, '0')}/'
                    '${dataSelecionada.year}'),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Escolher data'),
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: dataSelecionada,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (data != null) {
                      atualizarDialogo(() => dataSelecionada = data);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantidade = int.tryParse(quantidadeController.text);
                if (clienteSelecionado == null ||
                    produtoSelecionado == null ||
                    quantidade == null ||
                    quantidade <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Confira a quantidade da venda.')),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  Venda(
                    cliente: clienteSelecionado!,
                    produto: produtoSelecionado!,
                    quantidade: quantidade,
                    data: dataSelecionada,
                  ),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      if (existente == null) {
        vendas.add(resultado);
      } else {
        existente
          ..cliente = resultado.cliente
          ..produto = resultado.produto
          ..quantidade = resultado.quantidade
          ..data = resultado.data;
      }
    });
  }

  Future<void> excluirCliente(Cliente cliente) async {
    if (vendas.any((venda) => venda.cliente == cliente)) {
      mensagem('Não é possível excluir este cliente: ele possui vendas cadastradas.');
      return;
    }
    final confirmou = await confirmarExclusao('cliente ${cliente.nome}');
    if (confirmou) setState(() => clientes.remove(cliente));
  }

  Future<void> excluirProduto(Produto produto) async {
    if (vendas.any((venda) => venda.produto == produto)) {
      mensagem('Não é possível excluir este produto: ele aparece em vendas cadastradas.');
      return;
    }
    final confirmou = await confirmarExclusao('produto ${produto.nome}');
    if (confirmou) setState(() => produtos.remove(produto));
  }

  Future<void> excluirVenda(Venda venda) async {
    final confirmou = await confirmarExclusao('esta venda');
    if (confirmou) setState(() => vendas.remove(venda));
  }

  Future<bool> confirmarExclusao(String item) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir $item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }

  void mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Widget campoBusca({
    required String dica,
    required ValueChanged<String> aoMudar,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          labelText: dica,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
        ),
        onChanged: aoMudar,
      ),
    );
  }

  Widget botaoAdicionar(String texto, VoidCallback acao) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: acao,
          icon: const Icon(Icons.add),
          label: Text(texto),
        ),
      ),
    );
  }

  Widget telaClientes() {
    return _ListaClientes(
      clientes: clientes,
      busca: campoBusca,
      adicionar: () => cadastrarCliente(),
      editar: cadastrarCliente,
      excluir: excluirCliente,
      botaoAdicionar: botaoAdicionar,
    );
  }

  Widget telaProdutos() {
    return _ListaProdutos(
      produtos: produtos,
      dinheiro: dinheiro,
      busca: campoBusca,
      adicionar: () => cadastrarProduto(),
      editar: cadastrarProduto,
      excluir: excluirProduto,
      botaoAdicionar: botaoAdicionar,
    );
  }

  Widget telaVendas() {
    return _ListaVendas(
      vendas: vendas,
      dinheiro: dinheiro,
      busca: campoBusca,
      adicionar: () => cadastrarVenda(),
      editar: cadastrarVenda,
      excluir: excluirVenda,
      botaoAdicionar: botaoAdicionar,
    );
  }

  Widget telaConsulta() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('LISTA DE CLIENTES', style: Theme.of(context).textTheme.titleLarge),
        if (clientes.isEmpty)
          const Text('Nenhum cliente cadastrado.')
        else
          ...clientes.map((c) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(c.nome),
                  subtitle: Text(
                    'CPF: ${c.cpf}\nTelefone: ${c.telefone}\n'
                    'Turma: ${c.turma} | Turno: ${c.turno}',
                  ),
                  isThreeLine: true,
                ),
              )),
        const Divider(height: 32),
        Text('LISTA DE PRODUTOS', style: Theme.of(context).textTheme.titleLarge),
        if (produtos.isEmpty)
          const Text('Nenhum produto cadastrado.')
        else
          ...produtos.map((p) => Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(p.nome),
                  subtitle: Text(
                    'Descrição: ${p.descricao}\n'
                    'Unidade: ${p.unidade} | Valor: ${dinheiro(p.valor)}',
                  ),
                  isThreeLine: true,
                ),
              )),
        const Divider(height: 32),
        Text('LISTA DE VENDAS', style: Theme.of(context).textTheme.titleLarge),
        if (vendas.isEmpty)
          const Text('Nenhuma venda cadastrada.')
        else
          ...vendas.map((v) => Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: Text('${v.produto.nome} — ${v.cliente.nome}'),
                  subtitle: Text(
                    'Quantidade: ${v.quantidade}\n'
                    'Data: ${v.data.day.toString().padLeft(2, '0')}/'
                    '${v.data.month.toString().padLeft(2, '0')}/${v.data.year}\n'
                    'Valor total: ${dinheiro(v.total)}',
                  ),
                  isThreeLine: true,
                ),
              )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final telas = [
      telaClientes(),
      telaProdutos(),
      telaVendas(),
      telaConsulta(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Vendas - Cantina CEET'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              titulos[telaAtual],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(child: telas[telaAtual]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: telaAtual,
        onDestinationSelected: (index) => setState(() => telaAtual = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produtos',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Vendas',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Consulta',
          ),
        ],
      ),
    );
  }
}

class _ListaClientes extends StatefulWidget {
  final List<Cliente> clientes;
  final Widget Function({required String dica, required ValueChanged<String> aoMudar}) busca;
  final VoidCallback adicionar;
  final Future<void> Function(Cliente) editar;
  final Future<void> Function(Cliente) excluir;
  final Widget Function(String, VoidCallback) botaoAdicionar;

  const _ListaClientes({
    required this.clientes,
    required this.busca,
    required this.adicionar,
    required this.editar,
    required this.excluir,
    required this.botaoAdicionar,
  });

  @override
  State<_ListaClientes> createState() => _ListaClientesState();
}

class _ListaClientesState extends State<_ListaClientes> {
  String filtro = '';

  @override
  Widget build(BuildContext context) {
    final lista = widget.clientes.where((c) =>
      '${c.nome} ${c.cpf} ${c.telefone} ${c.turma} ${c.turno}'
          .toLowerCase().contains(filtro.toLowerCase())).toList();

    return Column(children: [
      widget.busca(dica: 'Buscar cliente', aoMudar: (v) => setState(() => filtro = v)),
      widget.botaoAdicionar('Cadastrar cliente', widget.adicionar),
      Expanded(
        child: lista.isEmpty
            ? const Center(child: Text('Nenhum cliente encontrado.'))
            : ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final c = lista[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      title: Text(c.nome),
                      subtitle: Text('CPF: ${c.cpf}\nTelefone: ${c.telefone}\n'
                          'Turma: ${c.turma} | Turno: ${c.turno}'),
                      isThreeLine: true,
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => widget.editar(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => widget.excluir(c),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

class _ListaProdutos extends StatefulWidget {
  final List<Produto> produtos;
  final String Function(double) dinheiro;
  final Widget Function({required String dica, required ValueChanged<String> aoMudar}) busca;
  final VoidCallback adicionar;
  final Future<void> Function(Produto) editar;
  final Future<void> Function(Produto) excluir;
  final Widget Function(String, VoidCallback) botaoAdicionar;

  const _ListaProdutos({
    required this.produtos,
    required this.dinheiro,
    required this.busca,
    required this.adicionar,
    required this.editar,
    required this.excluir,
    required this.botaoAdicionar,
  });

  @override
  State<_ListaProdutos> createState() => _ListaProdutosState();
}

class _ListaProdutosState extends State<_ListaProdutos> {
  String filtro = '';

  @override
  Widget build(BuildContext context) {
    final lista = widget.produtos.where((p) =>
      '${p.nome} ${p.descricao} ${p.unidade} ${p.valor}'
          .toLowerCase().contains(filtro.toLowerCase())).toList();

    return Column(children: [
      widget.busca(dica: 'Buscar produto', aoMudar: (v) => setState(() => filtro = v)),
      widget.botaoAdicionar('Cadastrar produto', widget.adicionar),
      Expanded(
        child: lista.isEmpty
            ? const Center(child: Text('Nenhum produto encontrado.'))
            : ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final p = lista[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      title: Text(p.nome),
                      subtitle: Text('Descrição: ${p.descricao}\n'
                          'Unidade: ${p.unidade} | Valor: ${widget.dinheiro(p.valor)}'),
                      isThreeLine: true,
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => widget.editar(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => widget.excluir(p),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

class _ListaVendas extends StatefulWidget {
  final List<Venda> vendas;
  final String Function(double) dinheiro;
  final Widget Function({required String dica, required ValueChanged<String> aoMudar}) busca;
  final VoidCallback adicionar;
  final Future<void> Function(Venda) editar;
  final Future<void> Function(Venda) excluir;
  final Widget Function(String, VoidCallback) botaoAdicionar;

  const _ListaVendas({
    required this.vendas,
    required this.dinheiro,
    required this.busca,
    required this.adicionar,
    required this.editar,
    required this.excluir,
    required this.botaoAdicionar,
  });

  @override
  State<_ListaVendas> createState() => _ListaVendasState();
}

class _ListaVendasState extends State<_ListaVendas> {
  String filtro = '';

  @override
  Widget build(BuildContext context) {
    final lista = widget.vendas.where((v) =>
      '${v.cliente.nome} ${v.produto.nome} ${v.quantidade} ${v.data}'
          .toLowerCase().contains(filtro.toLowerCase())).toList();

    return Column(children: [
      widget.busca(dica: 'Buscar venda por cliente ou produto', aoMudar: (v) => setState(() => filtro = v)),
      widget.botaoAdicionar('Registrar venda', widget.adicionar),
      Expanded(
        child: lista.isEmpty
            ? const Center(child: Text('Nenhuma venda encontrada.'))
            : ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final v = lista[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      title: Text('${v.produto.nome} — ${v.cliente.nome}'),
                      subtitle: Text('Quantidade: ${v.quantidade}\n'
                          'Data: ${v.data.day.toString().padLeft(2, '0')}/'
                          '${v.data.month.toString().padLeft(2, '0')}/${v.data.year}\n'
                          'Total: ${widget.dinheiro(v.total)}'),
                      isThreeLine: true,
                      trailing: Wrap(children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => widget.editar(v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => widget.excluir(v),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}
