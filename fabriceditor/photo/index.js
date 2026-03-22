var fs = require("fs");



const JSONData = {
    data: []
}

const group = [
    {
        label: '艺术',
        value: 'arts',
        start: 31,
        end: 60
    },
    {
        label: '风景',
        value: 'scenic',
        start: 0,
        end: 30
    }
]



const baseUrl = 'https://nihaojob.github.io/vue-fabric-editor-static/svg/'
JSONData.data = group.map((item, i) => {
    const list = []
    for (let index = item.start; index < item.end; index++) {
        list.push({
            "label": item.label + index,
            "value": i + '-' + index,
            "tempUrl": baseUrl + index + ".jpg",
            "src": baseUrl + index + ".jpg"
        })
    }
    return {
        label: item.label,
        value: item.value,
        list
    }
})

fs.writeFile('type.json', JSON.stringify(JSONData), function (err) {
    if (err) {
        return console.error(err);
    }
    console.log('写入成功')
});



