package org.hyn.titan.sensor

class Utils {


    companion object {
        fun addIfNonNull(optionsMap: MutableMap<String, Any>, fieldName: String, value: Any?) {
            if (value != null) {
                optionsMap.put(fieldName, value)
            }
        }
    }

}