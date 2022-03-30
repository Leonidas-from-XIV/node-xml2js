const stripBOM = str => str[0] === '\uFEFF' ? str.substring(1) : str

export {
  stripBOM
}
