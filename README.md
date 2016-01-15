## Usage:
download_fs.rb [<options>]

Examples:

    download_fs.rb -u http://domain.com/file
    download_fs.rb -u http://domain.com/file/
    download_fs.rb -u http://domain.com/file/list.htm
    download_fs.rb -u http://domain.com/file -d download -c 3 -t pdf,txt

Options:

    -u, --uri uri                    URI of file resource
    -d, --download_dir download_dir  Local directory to save files in (download by default)
    -c, --concurrency concurrency    Number of multiple requests to make (5 by default)
    -t, --filetype type1[,type2]     List of case-insensitive filetypes to download (all by default)
    -D, --debug                      Debug mode
    -v, --version                    Display script version
    -h, --help                       Display help messages


