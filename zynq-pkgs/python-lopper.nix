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
  setuptools,
  zynq-srcs,
}:

buildPythonPackage rec {
  pname = "python-lopper";
  version = if (src ? rev) then src.rev else "unstable";

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

  pyproject = true;

  build-system = [ setuptools ];

  pythonImportsCheck = [ "lopper" ];

  doCheck = false;

  meta = with lib; {
    description = "System device tree (S-DT) processor";
    homepage = "https://static.linaro.org/connect/lvc20/presentations/LVC20-314-0.pdf";
    license = licenses.bsd3;
  };
}
