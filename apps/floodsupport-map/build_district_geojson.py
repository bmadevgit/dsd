"""Build the public 50-district boundary file from the BMA open-data shapefile.

Source: https://data.go.th/th/dataset/50
Resource: https://data.bangkok.go.th/dataset/e537025b-1cf6-4c5b-8e46-c2e976f13283/resource/d7be7e84-9d84-4595-bf8f-79b0bc01f1ae/download/district-2.zip
Requires pyshp, pyproj and shapely. The source is WGS84 / UTM zone 47N (EPSG:32647).
"""

from __future__ import annotations

import io
import json
from pathlib import Path
import sys
import zipfile

import shapefile
from pyproj import Transformer
from shapely.geometry import mapping, shape as polygon_shape


OUTPUT = Path(r"C:\inetpub\wwwroot\now\districts.geojson")


def convert(zip_path: Path, output: Path = OUTPUT) -> None:
    with zipfile.ZipFile(zip_path) as archive:
        reader = shapefile.Reader(
            shp=io.BytesIO(archive.read("district.shp")),
            shx=io.BytesIO(archive.read("district.shx")),
            dbf=io.BytesIO(archive.read("district.dbf")),
            encoding="latin1",  # Thai source strings are not needed; API provides Thai names.
        )
        transformer = Transformer.from_crs(32647, 4326, always_xy=True)
        features = []
        for shape_record in reader.iterShapeRecords():
            record = shape_record.record.as_dict()
            # Simplify in metres before projection so the mobile payload stays small.
            geometry = mapping(polygon_shape(shape_record.shape.__geo_interface__).simplify(5, preserve_topology=True))

            def project_ring(ring):
                return [[round(lon, 6), round(lat, 6)] for lon, lat in
                        (transformer.transform(x, y) for x, y in ring)]

            if geometry["type"] == "Polygon":
                coordinates = [project_ring(ring) for ring in geometry["coordinates"]]
            elif geometry["type"] == "MultiPolygon":
                coordinates = [[project_ring(ring) for ring in polygon]
                               for polygon in geometry["coordinates"]]
            else:
                raise ValueError(f"Unexpected geometry: {geometry['type']}")
            features.append({
                "type": "Feature",
                "properties": {"districtCode": record["dcode"], "nameEnglish": record["dname_e"]},
                "geometry": {"type": geometry["type"], "coordinates": coordinates},
            })
    codes = [feature["properties"]["districtCode"] for feature in features]
    if len(features) != 50 or len(set(codes)) != 50:
        raise ValueError("Expected 50 unique Bangkok districts")
    output.write_text(json.dumps({"type": "FeatureCollection", "features": features},
                                 ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {len(features)} districts to {output}")


if __name__ == "__main__":
    convert(Path(sys.argv[1]))
