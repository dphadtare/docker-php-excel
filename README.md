# php_excel for Dockerized Environments

Dockerfile for building dockerized php_excel extension.

Since there is complexity in adding **php_excel** extension to a dockerized environment we are provide it here.
You can refer the manuall setup process [here](https://www.libxl.com/php.html)

## Using

Images are available with the following tags

* `dphadatare/phpexcel:latest`

#### Installation

Add below lines to your dockerfile

```dockerfile
COPY --from=dphadatare/phpexcel:latest /usr/local/lib/php/extensions/no-debug-non-zts-20180731/excel.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/
COPY --from=dphadatare/phpexcel:latest /usr/lib/libxl.so /usr/lib/
```

Optionaly, we can create the excel.ini file to configure excel, you can refer to the excel.ini file for reference. Copy that file to your repository and use below code line in dockerfile

````dockerfile
COPY ./docker/excel.ini /usr/local/etc/php/conf.d/excel.ini
````

## Usage Example

For examples please refer to link [here](https://github.com/iliaal/php_excel) 


