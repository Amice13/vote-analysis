find dist -type f -print0 | xargs -0 sed -i -r 's/=\"\//="/g' &&
find dist -type f -print0 | xargs -0 sed -i -r 's/:\"\/img/:"img/g' &&
find dist -type f -print0 | xargs -0 sed -i -r 's/:\"\/pdf/:"pdf/g' &&
find dist -type f -print0 | xargs -0 sed -i -r 's/:\"\/favicon/:"favicon/g' &&
find dist -type f -print0 | xargs -0 sed -i -r 's/\(\/nuxt\//(/g' &&
find dist -type f -print0 | xargs -0 sed -i -r 's/\/nuxt\//nuxt\//g'
find dist -type f -print0 | xargs -0 sed -i -r 's/http:\/\/localhost:3001/https:\/\/amice13.github.io\/vote-analysis\//g'