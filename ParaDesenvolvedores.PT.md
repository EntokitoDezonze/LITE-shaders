// Escrito por Javier Garduño - Traduzido por Entokito Dezonze.

Bem-vindo à edição comentada do MakeUp.

É meu desejo que o MakeUp possa ser usado como base para criar mais e melhores shaders, e é por isso que estou escrevendo este texto explicativo sobre o código-fonte.

Espero que os comentários que você encontrar aqui sejam úteis para modificar e/ou ampliar o MakeUp de acordo com suas necessidades.

Boa edição!

Organização dos arquivos de shader

### shaders/common

Para evitar código duplicado, os vários shaders usados nas diferentes dimensões do Minecraft referem-se a arquivos localizados neste diretório. É aqui que estão localizadas as rotinas principais para cada um dos diferentes tipos de blocos, bem como o restante das etapas do pipeline de trabalho do Optifine/Iris.

Os shaders de vértice e fragmento para cada etapa são separados em arquivos individuais, que podem ser claramente identificados pelo nome do arquivo em questão.

Não há necessariamente um arquivo aqui para cada etapa ou tipo de bloco, pois alguns blocos ou etapas compartilham muitas coisas em comum e, no MakeUp, são tratados de forma semelhante (ou quase igual).

Os melhores exemplos disso são solid_blocks_fragment.glsl e solid_blocks_vertex.glsl, que controlam o desenho da grande maioria dos blocos do jogo que não são translúcidos ou que requerem atenção muito especial.

Os nomes dos arquivos tentam ser explícitos sobre seu conteúdo ou finalidade.

### shaders/lang

Arquivos de tradução. Eles nomeiam as opções nas telas de configuração.

Os arquivos localizados neste diretório são tratados como “bibliotecas” e são chamados FORA da função principal do shader que os solicita (o que significa que eles não são inseridos dentro da função principal do shader específico). Normalmente, eles declaram funções ou valores usados pelo solicitante.

Os nomes dos arquivos tentam ser explícitos sobre seu conteúdo ou finalidade.

### shaders/src

Os arquivos aqui têm uma função semelhante aos arquivos em shaders/lib. A diferença está na maneira como eles são inseridos no código do shader solicitante.

Nesse caso, o código deve ser inserido DENTRO da função principal do shader específico. São trechos simples de código que, quando usados várias vezes, são escritos apenas uma vez aqui e incluídos de forma “suja” no código, sem serem, estritamente falando, funções.

### shaders/textures

Como o nome sugere, é aqui que as texturas usadas pelo shader são armazenadas.

### shaders/worldX

As pastas bem conhecidas que hospedam os shaders correspondentes a cada dimensão:

    world0: Overworld
    world-1: Nether
    world1: The End

Os shaders usados para qualquer outra dimensão não especificada são descendentes diretos do diretório “shaders”.

-----

# Fluxo principal de desenho

Buffers

Os buffers são usados e atribuídos da seguinte maneira:

- noisetex: Armazena as normais da água em dois canais, com o terceiro componente sendo calculado em tempo de execução. (RG8)
- colortex0: Bluenoise (não utilizado). (R8)
    - colortex1: Buffer principal. Quando o DOF está ativo, são quatro canais, com o quarto canal armazenando a profundidade da cena para antialiasing e para evitar mudanças repentinas de foco devido ao tremido da câmera. (Sem DOF: R11F_G11F_B10F, com DOF: RGBA16)
    - colortex2: Não utilizado. (R8)
- colortex3: Armazena o histórico usado para amostragem temporal (TAA). Quando o DOF está ativo, são quatro canais, com o quarto canal armazenando a profundidade da cena para antialiasing e para evitar mudanças repentinas de foco devido ao tremido da câmera. (Sem DOF: R11F_G11F_B10F, com DOF: RGBA16)
    - gaux1: Armazena uma versão da cena que será usada para reflexos e refrações no espaço da tela. Depois de ser usado para isso, é usado como auxiliar para armazenar o bloom da cena. (R11F_G11F_B10F)
    - gaux2: Armazena o mapa de nuvens. (R8)
- gaux3: Armazena o valor histórico da exposição automática da cena. O valor da exposição automática é obtido fazendo uma média ponderada com o valor deste canal e o calculado na cena atual para criar uma transição gradual da exposição automática ao longo do tempo. Sim, é excessivo usar um buffer inteiro para armazenar um único valor de ponto flutuante, mas é o que é. Ele só é usado se o método de exposição automática padrão for usado. (R16F)
- gaux4: Armazena a cor do céu. (sem nuvens ou outros objetos) para dar a cor que deve ser usada na névoa (sim, a névoa é sempre da cor do “céu”). Dessa forma, os objetos ficam desfocados e se misturam com o céu ao longe.

-----

# Etapas gerais de desenho

Esta é apenas uma descrição geral das etapas envolvidas no desenho de uma cena típica. Ela não contém todos os detalhes e pode variar dependendo da dimensão e das opções ativadas.

1. A cor do céu ou da distância infinita é calculada em “prepare”. Essa cor é escrita em dois lugares:
- colortex1: Será usada posteriormente para escrever os blocos sólidos ali.
 - gaux4: este buffer será usado para extrair a cor da névoa dele.

2. Em gbuffers_skybasic, elementos como estrelas são desenhados sobre o céu desenhado anteriormente. Posteriormente, elementos texturizados do céu são desenhados (gbuffers_skytextured). Tudo isso é gravado em colortex1.

3. Blocos sólidos são criados nos programas gbuffer correspondentes. Aqui, a iluminação dos blocos é calculada (incluindo sombras).
O resultado será escrito em:
 - colortex1

4. Em diferido, nuvens e oclusão ambiente serão calculadas. Os resultados serão escritos em:
 - colortex1: A cena calculada é escrita aqui, o canal “a” armazenará a profundidade (somente se fizer sentido).
 - gaux1: Será usado posteriormente como fonte de dados para o cálculo de reflexos e refrações no espaço da tela na próxima etapa.

5. Blocos translúcidos são desenhados. As nuvens são recalculadas em baixa qualidade para serem usadas em reflexos. gaux1 é lido como fonte para refrações e reflexos no espaço da tela. O canal alfa continua a ser usado para armazenar profundidade. Os resultados são gravados em:
- colortex1

6. Em Composite, o nível de exposição automática do quadro atual é calculado e ponderado com o valor histórico salvo em gaux3. A iluminação volumétrica também é calculada e o bloom é preparado. A exposição automática não leva em consideração nenhum desses efeitos posteriores.
“Preparar o bloom” significa salvar uma versão da cena atual com o nível de exposição aplicado em gaux1.
O valor de exposição automática calculado também é salvo em gaux3.

7. Em Composite1, o DOF é calculado e o bloom é aplicado. Para aplicar o bloom, um nível de mipmap do buffer gaux3 calculado na etapa anterior é lido. O resultado é gravado em colortex1

8. Em Composite2, AA e desfoque de movimento são calculados. O resultado é gravado em colortex0. Se a superamostragem temporal estiver ativada, o histórico é gravado em colortex3.

9. Finalmente, efeitos de pós-processamento, como aberração cromática, exposição automática, mapeamento de tons e auxílios para daltonismo, são aplicados em Final.
A imagem é então enviada para a tela.

-----

Revise o restante dos diretórios ou código-fonte para encontrar informações relacionadas a esse elemento.