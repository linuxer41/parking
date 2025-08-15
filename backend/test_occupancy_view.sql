-- Script para probar la vista de ocupación
-- Este script verifica que todos los elementos de tipo 'spot' aparecen en la vista

-- 1. Verificar que todos los elementos de tipo 'spot' están en la vista
SELECT 
  'Elementos totales de tipo spot' as description,
  COUNT(*) as count
FROM t_element 
WHERE type = 'spot' AND "deletedAt" IS NULL

UNION ALL

SELECT 
  'Elementos en la vista de ocupación' as description,
  COUNT(*) as count
FROM v_element_occupancy

UNION ALL

SELECT 
  'Elementos que faltan en la vista' as description,
  COUNT(*) as count
FROM t_element e
LEFT JOIN v_element_occupancy v ON v."elementId" = e.id
WHERE e.type = 'spot' 
  AND e."deletedAt" IS NULL 
  AND v."elementId" IS NULL;

-- 2. Verificar el estado de ocupación de todos los elementos
SELECT 
  e.id,
  e.name,
  e.type,
  e."isActive",
  v.status,
  v.access IS NOT NULL as has_access,
  v.reservation IS NOT NULL as has_reservation,
  v.subscription IS NOT NULL as has_subscription
FROM t_element e
LEFT JOIN v_element_occupancy v ON v."elementId" = e.id
WHERE e.type = 'spot' AND e."deletedAt" IS NULL
ORDER BY e.name;

-- 3. Verificar elementos con occupancy null
SELECT 
  e.id,
  e.name,
  e.type,
  e."isActive",
  'Elemento sin datos de ocupación' as issue
FROM t_element e
LEFT JOIN v_element_occupancy v ON v."elementId" = e.id
WHERE e.type = 'spot' 
  AND e."deletedAt" IS NULL 
  AND v."elementId" IS NULL;
