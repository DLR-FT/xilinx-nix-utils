{
  anytree,
  buildPythonPackage,
  configparser,
  humanfriendly,
  lib,
  libfdt,
  packaging,
  pyyaml,
  ruamel-yaml,
  zynq-srcs,
}:

buildPythonPackage rec {
  pname = "python-lopper";
  version = src.rev;

  src = zynq-srcs.lopper-src;

  propagatedBuildInputs = [
    anytree
    configparser
    humanfriendly
    libfdt
    packaging
    pyyaml
    ruamel-yaml
  ];

  pythonImportsCheck = [ "lopper" ];

  doCheck = false;

  meta = with lib; {
    description = "System device tree (S-DT) processor";
    homepage = "https://static.linaro.org/connect/lvc20/presentations/LVC20-314-0.pdf";
    license = licenses.bsd3;
  };
}
