# Configlet - JSON-Schema-based Configuration Loader

Configlet loads your configuration from your config files, environment variables, and commandline arguments (in that order), merge them, and then validate the results against the JSON-Schema you specified, via [schemalet](https://github.com/yinso/schemalet).

## Install

    npm install configlet

## Usage

    var Config = require('configlet')

    var config = Config.parseSync(<your JSON schema here>); // a parse option can be added, see below 

### Configuration Files

By default, Configlet looks for the configuration files in the `./config/` directory, relative to `process.cwd()` (both are parse options that can be changed).

The configuration files should hold values that are valid according to your JSON-Schema. They do not have to hold every single value as they can be merged in via a subsequently loaded configuration file, the environment variables, or the command line arguments.

The configuration files are loaded in the following order (this can also be configured):

    default.<ext>
    <environment>.<ext> // from NODE_ENV || ENV || 'development'
    <hostname>.<ext> // from os.hostname()
    local.<ext>

The formats supported by default are JSON and YAML for the extensions `.json`, `.yml`, `.yaml`, and it can be extended as well via parse options.

### Environment Variables

By default, Configlet reads your environment variable based on the paths of your JSON-Schema object.

For example, let's say that we have a schema for the following object:

    {
      database: {
        username: <string>,
        password: <string>,
        host: <string>,
        port: <integer>
      },
    }

Then Configlet would read from the following fields:

    DATABASE_USERNAME
    DATABASE_PASSWORD
    DATABASE_HOST
    DATABASE_PORT


### Commandline Arguments

Similarly, Configlet reads your commandline arguments based ont he paths of your JSON-Schema object.

For the same object above, Configlet would look for the following commandline arguments to read from:

    --database.username
    --database.password
    --database.host
    --database.port

## API

### `.parseSync(<schema>, <parseOptions> = {});`

The schema used here is the schema recognized by [`schemalet`](http://github.com/yinso/schemalet). It means that you can generate a class-based object via `configlet`, instead of just generating plain objects.

Since this is a sync-version, it means that it blocks until the files are read. This is fine for the starting phase of the program, since the program cannot continue until the config files are loaded. There is an async version as well.

## Parse Options

The following are the parse options to pass into `.parseSync`. The ones that have defaults are listed with `= <default value>`.

### `rootPath = process.cwd()`

This can be used to change the default location of the configuration files. This can be changed to say the `$HOME` environment variable to read from user's home directory.

### `basePath = './config/'`

This is the folder + filename prefix to look for within the rootPath, for example, the default is `./config`, which when combined with `rootPath` as well as `loadOrder`, we would look for the following:

    <rootPath><basePath><loadOrderItem>

i.e.

    $PWD/config/default
    $PWD/config/<env>
    $PWD/config/<hostname>
    $PWD/config/local

This can be used to add a prefix to load a different set of config files, for example, if we specify `./config/foo-`, we would then be loading the following:

    $PWD/config/foo-default
    $PWD/config/foo-<env>
    $PWD/config/foo-<hostname>
    $PWD/config/foo-local

This is useful for loading a secondary set of configuration files that is completely different from the primary configuration files, i.e. 

    var defaultConfig = Configlet.parseSync(<schema1>, {
      basePath: './config'
    });

    var nextConfig = Configlet.parseSync(<fooSchema>, {
      basePath: './config/foo-'
    });

For files that share the same schema, use `loadOrder` options to control their loading instead.

### `loadOrder = function () { return [ < list of file names> ]; }`

This is a function that returns the list of the filenames to be used for loading. By default it's list function:

    function () {
      return [
        'default',
        process.env.NODE_ENV || process.env.ENV || 'development',
        os.hostname(),
        'local'
      ];
    }

You can replace it with your own custom load order function:

    var res = Configlet.parseSync(<schema>, {
      loadOrder: function () { return [ ... ]; }
    });

### `extMap = { <extname>: <parser>, ... }`

If you want to support additional config extension formats (like [`json5`](http://json5.org/)), you can introduce it via `configExpMap` as follows:

    var JSON5 = require('json5');
    var res = Configlet.parseSync(<schema>, {
      extMap: {
        'json5': JSON5.parse
      }
    });

The added formats would be merged with the existing formats, so you can still use `.json` or `.yaml`.

### `argv = process.argv` 

Instead of using `process.argv`, you can supply your own commandline argument compatible arguments here. This comes in handy when you want to have custom commandline arguments.

Although the first two arguments of `process.argv` are the program (like `node`, or `coffee`) and the script (the main file invoked), they are removed as part of the default argument process. You do not need to pass such two arguments in if you use this option.

### `env = process.env`

Instead of using `process.env`, you can supply your own environment variables here. This comes in handy when you want to have custom environment variables.

