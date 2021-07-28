# Java Decompiler
JD is wrapper for Procyon. Procyon is a Java decompiler handling language enhancements from Java 5 and beyond that
most other decompilers don't.  

## Install

### Procyon
```bash
sudo apt install procyon-decompiler
```

### JD
```bash
sudo cp jd.sh /usr/bin/jd
sudo chmod 0644 /usr/bin/jd
sudo chmod +x /usr/bin/jd
```

## Usage
```bash
jd FILE_NAME
```

## Example 
```bash
jd 'SomeClassName.$1.class'
```
