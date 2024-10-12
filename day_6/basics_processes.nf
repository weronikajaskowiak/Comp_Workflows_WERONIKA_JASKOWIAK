params.step = 0
params.zip = 'zip'


process SAYHELLO {
    debug true
    output:
    stdout

    script:
    """
    echo "Hello World!"
    """
}

process SAYHELLO_PYTHON {
    debug true
    output:
    stdout

    script:
    """
    #!/usr/bin/env python3
    print("Hello World")
    """
}

process SAYHELLO_PARAM {
    debug true
    input:
    val greeting

    output:
    stdout

    script:
    """
    echo "${greeting}"
    """
}
process SAYHELLO_FILE {
    debug true
    input:
    val greeting

    output:
    path "greeting.txt"

    script:
    """
    echo "${greeting}" > greeting.txt
    """
}

process UPPERCASE {
    debug true

    input:
    val greeting

    output:
    path "uppercase_greeting.txt"

    script:
    """
    echo "${greeting.toUpperCase()}" > uppercase_greeting.txt
    """
}

process PRINTUPPER {
    debug true
    input:
    path input_file

    output:
    stdout

    script:
    """
    cat ${input_file}
    """
}

process ZIPFILE {
    debug true
    input:
    path uppercase_file

    output:
    path "output_compressed.*"

    when:
    params.zip in ['zip', 'gzip', 'bzip2']

    script:
    def zip_format = params.zip

    if (zip_format == 'zip') {
        """
        zip output_compressed.zip ${uppercase_file}
        """
    } else if (zip_format == 'gzip') {
        """
        gzip -c ${uppercase_file} > output_compressed.gz
        """
    } else if (zip_format == 'bzip2') {
        """
        bzip2 -c ${uppercase_file} > output_compressed.bz2
        """
    }
}

process ZIP_ALL {
    debug true

    input:
    path uppercase_file

    output:
    path 'greeting_uppercase.*'

    script:
    """
    zip greeting_uppercase.zip $uppercase_file

    gzip -k $uppercase_file -c > greeting_uppercase.txt.gz

    bzip2 -k $uppercase_file -c > greeting_uppercase.txt.bz2

    """
}

process WRITEOFFILE {
    input:
    val in_ch
    output:
    path 'names.tsv'
    script:
    """
    echo "name\ttitle" > names.tsv
    echo "${in_ch.name}\t${in_ch.title}" >> names.tsv
    """

}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")

        // Call UPPERCASE process to create the file
        out_ch = UPPERCASE(greeting_ch)

        // Call ZIPFILE process to zip the output based on the param.zip
        zip_out = ZIPFILE(out_ch)

        // View the path of the zipped file
        zip_out.view { "Zipped file: ${it}" }
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch = ZIP_ALL(out_ch)
        out_ch.view()
    }
    //Task 9
    if (params.step == 9){
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )
         in_ch
            | WRITEOFFILE
            | collectFile(newLine: true, name: "results/names.tsv", keepHeader: true)
            | view()


    }

}
