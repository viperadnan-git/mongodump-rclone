# mongodump-rclone

> **⚠️ ARCHIVED - This project is now read-only**
>
> This project has been superseded by [**dbstash**](https://github.com/viperadnan-git/dbstash), a complete rewrite in Go that supports multiple databases (PostgreSQL, MongoDB, MySQL, MariaDB, Redis) with better performance, scheduling, and features.
>
> **Please use [dbstash](https://github.com/viperadnan-git/dbstash) for new projects.**

This is a simple script to backup a MongoDB database using `mongodump` and upload it to a remote storage using `rclone`. It is intended to be used as a cron job.

## Usage

```bash
bash ./entrypoint.sh
```

## Usage with Docker

Run the following command to backup a MongoDB database and upload it to a remote storage using `rclone`.

```bash
docker run \
  -e MONGO_DB=mydb \ 
  -e MONGO_COLLECTION=mycollection \
  -e RCLONE_REMOTE=myremote \
  -e RCLONE_REMOTE_PATH=/path/to/remote \ 
  -e MONGO_URI=mongodb://myuser:xxxxxxxxxx@xxxxxx:27017/mydb \ 
  -v $HOME/.config/rclone:/config/rclone \ 
  --rm \ 
  -it \
  mongodump-rclone
```

## Usage with Docker Compose

You can use the following `docker-compose.yml` file to backup a MongoDB database and upload it to a remote storage using `rclone`.

```yaml
services:
  mongodump:
    image: mongodump-rclone
    environment:
      - MONGO_DB=mydb
      - MONGO_COLLECTION=mycollection
      - RCLONE_REMOTE=myremote
      - RCLONE_REMOTE_PATH=/path/to/remote
      - MONGO_URI=mongodb://myuser:xxxxxxxxxx@xxxxxx:27017/mydb
    volumes:
      - /home/user/.config/rclone:/config/rclone
  mongoexport:
    image: mongodump-rclone
    environment:
      - USE_MONGOEXPORT=true
      - MONGO_DB=mydb
      - MONGO_COLLECTION=mycollection
      - RCLONE_REMOTE=myremote
      - RCLONE_REMOTE_PATH=/path/to/remote
      - MONGO_URI=mongodb://myuser:xxxxxxxxxx@xxxxxx:27017/mydb
    volumes:
      - /home/user/.config/rclone:/config/rclone
```

Run the following command to start the services.

```bash
docker-compose up # for both services
docker-compose up mongodump # for mongodump
docker-compose up mongoexport # for mongoexport
```

## Configuration

The backup can be performed using the `mongodump` command or the `mongoexport` command. The script will use `mongodump` by default. You can change this behavior by setting the `USE_MONGOEXPORT` environment variable to `true`.

The script uses environment variables to configure the backup and upload process.

### mongodump

| Variable                  | Description                                                                 | Required | Default |
|---------------------------|-----------------------------------------------------------------------------|----------|---------|
| `RCLONE_CONFIG`           | The content of the rclone configuration without it's name.                  | No       | None    |
| `RCLONE_REMOTE`           | The name of the rclone remote to upload the backup to.                      | No       | default |
| `RCLONE_REMOTE_PATH`      | The path on the remote storage where the backup will be uploaded.           | No       | /       |
| `MONGO_DB`                | The name of the MongoDB database to backup.                                 | No       | None    |
| `MONGO_COLLECTION`        | The name of the MongoDB collection to backup.                               | No       | None    |
| `FILENAME`                | The base name of the backup file.                                           | No       | mongodb |
| `FILENAME_TIMESTAMP`      | Whether to include a timestamp in the backup file name (true/false).        | No       | true    |
| `MONGO_URI`               | The MongoDB connection URI.                                                 | No       | None    |
| `MONGODUMP_ARGS`          | Additional arguments to pass to the `mongodump` command.                    | No       | None    |
| `RCLONE_ARGS`             | Additional arguments to pass to the `rclone rcat` command.                  | No       | None    |

### mongoexport 

| Variable             | Description                                                                  | Required | Default   |
| -------------------- | ---------------------------------------------------------------------------- | -------- | --------- |
| `RCLONE_CONFIG`      | The configuration for rclone.                                                | Yes      | None      |
| `RCLONE_REMOTE`      | The name of the remote to use with rclone.                                   | No       | "default" |
| `RCLONE_ARGS`        | Additional arguments to pass to rclone.                                      | No       | None      |
| `RCLONE_REMOTE_PATH` | The path in the remote to store the exported data.                           | No       | "/"       |
| `MONGOEXPORT_ARGS`   | Additional arguments to pass to mongoexport.                                 | No       | None      |
| `FILENAME`           | The base name of the output file.                                            | No       | "mongodb" |
| `MONGO_DB`           | The name of the MongoDB database to export.                                  | Yes      | None      |
| `MONGO_COLLECTION`   | The name of the MongoDB collection to export.                                | Yes      | None      |
| `FILENAME_TIMESTAMP` | Whether to append a timestamp to the filename.                               | No       | "true"    |
| `MONGOEXPORT_TYPE`   | The type of the export file (json or csv).                                   | Yes      | "json"    |
| `MONGO_URI`          | The MongoDB connection string.                                               | No       | None      |

In case the `MONGO_URI` is not provided, the script will try to connect to the MongoDB server running on `localhost` using the default port `27017`.

If you want to use a rclone config file, you can mount the directory containing the file to `/config/rclone`. i.e `docker run -v /home/user/.config/rclone:/config/rclone`.

## Contributing

If you find a bug or have an idea for a new feature, please open an issue or submit a pull request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](./LICENSE) file for details.