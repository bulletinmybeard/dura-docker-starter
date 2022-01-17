const { existsSync, statSync } = require('fs')

const args = (process.argv).slice(2);

let argsObject = {};

if (args.length) {
    argsObject = args.reduce((args, arg) => {
        const matches = arg.match(new RegExp('^--([-a-z]+)=(.*)$'));
        if (matches !== null) {
            const [, key, value] = matches;
            args[key] = (typeof value === 'string'
                && ['true', 'false'].includes(value))
                ? (value === 'true')
                : value;
        }
        return args;
    }, {});
}

let printObject = {
    event: argsObject.event,
    argsObject,
};

if (!('event' in argsObject)) {
    console.log('event argument missing!')
    return
}

const isMacOS = (process.platform === 'darwin')
printObject.isMacOS = isMacOS

const gitReposPath = isMacOS
    ? process.env['HOST_VOLUME_PATH']
    : process.env['CONTAINER_MOUNT_PATH']
// printObject.gitReposPath = gitReposPath

const regex = `${printObject.gitReposPath}\\/([-.\\w]+)\\s{1}([\\sa-zA-Z]+)$`
// printObject.regex = regex

const lastEvent = (argsObject.event).match(new RegExp(regex, 'gi'))
// printObject.lastEvent = lastEvent

if (lastEvent && lastEvent.length) {
    const [dirPath, ...eventNames] = lastEvent[0].split(' ')

    // const dirCreated = [
    //     'OwnerModified',
    //     'Created',
    //     'PlatformSpecific',
    //     'AttributeModified',
    //     'IsDir',
    // ]

    // const dirVerified = eventNames.every(item => dirCreated.includes(item))
    // printObject.dirVerified = dirVerified

    try {
        const stats = statSync(dirPath)

        if (!stats) {
            // TODO: Directory deleted or symlink removed
            console.log('removed')
        } else if (stats.isDirectory()) {

            // printObject.dirPath = dirPath
            // printObject.eventNames = eventNames
            // printObject.gitDirExists = existsSync(dirPath)
            // printObject.isDir = stats.isDirectory()
            // printObject.isFile = stats.isFile()
            //
            // console.log(printObject)
            console.log('created')
        }
    } catch {}
}

