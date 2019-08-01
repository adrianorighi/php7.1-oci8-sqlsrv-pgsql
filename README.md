# Docker Php 7.1

Configuração de imagem Docker:

- PHP 7.1
- Apache
- Oci8
- Postgresql
- SQL Server
- Composer
- Xdebug

### Iniciar container

```bash
$ docker run -d -p 80:8080 -v $(pwd):/var/www/html --name nome-container adrianorighi/
```

### Configuração - Xdebug

- Host: 172.17.0.1
- Port: 9000

#### VS Code

1. Extensão a ser instalada: [PHP Debug](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug);
2. Em Debug (menu lateral), clicar em "Configure or Fix 'launch.json'";
3. Adicionar o conteúdo abaixo no arquivo `launch.json` aberto:

```json
{
    "name": "App",
    "type": "php",
    "request": "launch",
    "pathMappings": {
        "/var/www/html": "${workspaceFolder}"
    },
    "port": 9000,
    "log": true
}
```

4. Salvar e clicar no "play" para iniciar a execução.