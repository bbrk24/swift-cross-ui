package dev.swiftcrossui.androidbackend.temporal

import java.time.OffsetDateTime
import java.time.Instant
import java.time.ZoneId

data class CustomDate(val unixEpoch: Double) {
    val unixEpochMillis get() = (unixEpoch * 1000.0).toLong()
    
    fun toOffsetDateTime(zoneId: ZoneId) = OffsetDateTime.ofInstant(
        Instant.ofEpochSecond(
            unixEpoch.toLong(),
            ((unixEpoch % 1.0) * 1000000000.0).toLong()
        ),
        zoneId
    )
}
