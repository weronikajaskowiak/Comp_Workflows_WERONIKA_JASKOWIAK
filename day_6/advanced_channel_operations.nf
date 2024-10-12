params.step = 0

workflow {
    // Task 1 - Read in the samplesheet.
    if (params.step == 1) {
        csv_ch = Channel.fromPath('samplesheet.csv').splitCsv(header: true, sep: ',')
        csv_ch.view()
    }

    // Task 2 - Create a meta-map with metadata and filenames
   if (params.step == 2) {
    csv_ch = Channel.fromPath('samplesheet.csv').splitCsv(header: true, sep: ',')

    meta_map = csv_ch.map { row ->
        [
            [
                sample: row.sample,
                strandedness: row.strandedness
            ],
            [row.fastq_1, row.fastq_2]
        ]
    }

    meta_map.view()
}


    // Task 3 - Split the channel based on strandedness
    if (params.step == 3) {
        csv_ch = Channel.fromPath('samplesheet.csv').splitCsv(header: true, sep: ',')

        meta_map = csv_ch.map { row ->
            [
                [
                    sample: row.sample,
                    strandedness: row.strandedness
                ],
                [row.fastq_1, row.fastq_2]
            ]
    }


    branches = meta_map.branch {
        auto: it[0].strandedness == 'auto'
        forward: it[0].strandedness == 'forward'
        reverse: it[0].strandedness == 'reverse'
    }


    branches.auto.view { "Auto: ${it}" }
    branches.forward.view {"Forward: ${it}"}
    branches.reverse.view {"Reverse: ${it}"}
}


    // Task 4 - Group together all files with the same sample-id and strandedness value.
    if (params.step == 4) {
    csv_ch = Channel.fromPath('samplesheet.csv').splitCsv(header: true, sep: ',')

    meta_map = csv_ch.map { row ->
        [
            sample: row.sample,
            strandedness: row.strandedness,
            fastq_files: [row.fastq_1, row.fastq_2]
        ]
    }


    grouped_ch = meta_map
        .map { meta_data ->
            tuple([meta_data.sample, meta_data.strandedness], meta_data.fastq_files)
        }
        .groupTuple()

    grouped_ch.view()

}
}
