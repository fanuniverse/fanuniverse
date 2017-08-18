const fs = require('fs');
const path = require('path');
const revHash = require('rev-hash');
const gzip = require('gzipme');

const exec = require('util')
  .promisify(require('child_process').exec);

async function build() {
  const commands = [
    run('npm run postcss'),
    run('npm run rollup-app'),
    run('npm run rollup-vendor')
  ];

  (await Promise.all(commands)).forEach(logOutput);

  const paths = [
    '../priv/static/app.css',
    '../priv/static/app.js',
    '../priv/static/vendor.js'
  ];
  const manifestPath = '../priv/static/manifest.json';

  const manifest = Object.assign(...paths.map((sourcePath) => {
    const hash = revHash(fs.readFileSync(sourcePath));

    const { dir, base, name, ext } = path.parse(sourcePath);
    const revBase = `${name}-${hash}${ext}`;
    const targetPath = path.join(dir, revBase);

    fs.renameSync(sourcePath, targetPath);
    gzip(targetPath, targetPath + '.gz', 'best');

    return { [base]: revBase };
  }));

  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
}

async function run(cmd) {
  const buildEnv = Object.create(process.env);
  buildEnv.NODE_ENV = 'production';

  const { stdout, stderr } = await exec(cmd, { env: buildEnv });
  return { cmd: cmd, stdout: stdout, stderr: stderr };
}

function logOutput({ cmd, stdout, stderr }) {
  console.log('\x1b[36m%s\x1b[0m', `=> ${cmd}`);
  console.log(stdout);
  console.log(stderr);
}

build();
