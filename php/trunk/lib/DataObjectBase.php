<?php

Class DataObjectBase {

	protected $arr;

	protected function __get($property) {
		if (array_key_exists($property, $this->arr)) {
			return $this->arr[$property];
		} else {
			throw new Exception("Can't read a property: $property\n");
		}
	}

	protected function __set($property, $value) {
		if (array_key_exists($property, $this->arr)) {
			$this->arr[$property] = $value;
		} else {
			throw new Exception("Can't write a property: $property\n");
		}
	}

	public function getProps() {
		return array_keys($this->arr);
	}

	public function getValues() {
		return array_values($this->arr);
	}
}

?>