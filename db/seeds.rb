# frozen_string_literal: true

# 1. Admin Users
User.find_or_create_by!(email: "prueba@canchas.com") do |u|
  u.password = "123"
  u.role = :admin
end

User.find_or_create_by!(email: "profe@canchas.com") do |u|
  u.password = "123"
  u.role = :admin
end

# 2. Canchas (Fútbol 5)
c1 = Court.find_or_create_by!(name: "Cancha 1 - Sintético Techada") do |c|
  c.price = 28000
  c.covered = true
end

c2 = Court.find_or_create_by!(name: "Cancha 2 - Aire Libre Iluminada") do |c|
  c.price = 24000
  c.covered = false
end

# 3. Franjas Horarias (10:00 a 01:00 hs, en intervalos de 1 hora)
# Días: 0..7 (0=Domingo, 1=Lunes ... 6=Sábado, 7=Domingo)
(0..7).each do |day|
  (10..24).each do |hour|
    start_hour = hour == 24 ? 0 : hour
    end_hour = start_hour == 23 ? 0 : (start_hour == 0 ? 1 : start_hour + 1)

    st = Time.zone.parse(format("%02d:00", start_hour))
    et = Time.zone.parse(format("%02d:00", end_hour))

    TimeSlot.find_or_create_by!(day_of_week: day, start_time: st, end_time: et)
  end
end

puts "Seeds loaded successfully. Total TimeSlots: #{TimeSlot.count}"
