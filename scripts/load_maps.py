#!/usr/bin/env python3

# Usage: load_maps.py {s3_prefix_url} {target_dir}


import sys
import bz2
import shutil
import tempfile

from os.path import basename
from pathlib import Path
from functools import cached_property
from urllib.parse import urlparse
from typing import Generator, Any, BinaryIO
from dataclasses import dataclass

import boto3


@dataclass
class S3Path:
    bucket: str
    key: str

    @property
    def base_name(self):
        return basename(self.key)

    @classmethod
    def from_url(cls, url: str):
        result = urlparse(url)

        if result.scheme == "s3" and result.netloc is not None:
            return cls(result.netloc, result.path)
    
        return None
    
    @classmethod
    def from_object(cls, bucket: str, obj: dict):
        return cls(bucket, obj["Key"])
    
    def _from_object(self, obj: dict):
        return self.from_object(self.bucket, obj)

    @property
    def _s3_kwargs(self):
        return {
            "Bucket": self.bucket,
            "Key": self.key
        }

    def ls(self, client) -> Generator["S3Path", Any, Any]:
        paginator = client.get_paginator("list_objects_v2")
  
        for page in paginator.paginate(Bucket=self.bucket, Prefix=self.key.strip("/")):
            yield from map(self._from_object, page["Contents"])

    def get(self, client, fd: BinaryIO):
        client.download_fileobj(self.bucket, self.key, fd)
    
    @property
    def url(self):
        return f"s3://{self.bucket}{self.key}"


@dataclass
class RuntimeContext:
    map_location: S3Path
    target_dir: Path
    session: boto3.Session = boto3.Session()

    @cached_property
    def s3(self):
        return boto3.client("s3")
    
    @property
    def maps(self):
        for obj in self.map_location.ls(self.s3):
            if obj.key.endswith(".bsp.bz2"):
                yield obj

    def download_map(self, tmpdir: Path, obj: S3Path):
            archive_name = obj.base_name
            bsp_name = archive_name.rstrip(".bz2")

            tmpfile = tmpdir / archive_name
            mapfile = self.target_dir / bsp_name

            with tmpfile.open("wb") as fd:
                print(f"Downloading {archive_name} from {self.map_location.url}...")
                obj.get(self.s3, fd)
            with bz2.BZ2File(tmpfile) as bz2_fd, mapfile.open("wb") as bsp_fd:
                print(f"Extracting {bsp_name} to {str(self.target_dir)}")
                shutil.copyfileobj(bz2_fd, bsp_fd)

    def download_maps(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpdir = Path(tmpdir).resolve()
            for obj in self.maps:
                self.download_map(tmpdir, obj)


def parse_args() -> RuntimeContext:
    s3_prefix_url = S3Path.from_url(sys.argv[1])
    target_path = Path(sys.argv[2]).resolve()
    return RuntimeContext(s3_prefix_url, target_path)


def main():
    ctx = parse_args()
    print(f"Beginning map download...")
    ctx.download_maps()
    print(f"Completed map download!")


if __name__ == "__main__":
    sys.exit(main())
